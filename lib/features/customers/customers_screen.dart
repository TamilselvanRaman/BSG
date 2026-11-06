import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';
import '../../data/models/seller_load.dart';
import '../seller_loads/create_seller_load_dialog.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  int _activeSegment = 0; // 0: Wholesale Buyers, 1: Farmers & Inward Loads
  String _searchQuery = '';
  String _buyerFilter = 'All'; // 'All', 'Dues', 'Settled'
  String _loadFilter = 'All'; // 'All', 'Arrived', 'Partially Sold', 'Settled'

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final loads = ref.watch(sellerLoadsProvider);

    final buyers = customers.where((c) => c.customerType == CustomerType.buyer || c.customerType == CustomerType.both).toList();

    final filteredBuyers = buyers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
      if (!matchesSearch) return false;
      if (_buyerFilter == 'Dues') return c.openingBalance > 0;
      if (_buyerFilter == 'Settled') return c.openingBalance == 0;
      return true;
    }).toList();

    final filteredLoads = loads.where((l) {
      final matchesSearch = l.loadNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.sellerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.commodity.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_loadFilter == 'Arrived') return l.status == SellerLoadStatus.arrived;
      if (_loadFilter == 'Partially Sold') return l.status == SellerLoadStatus.partiallySold;
      if (_loadFilter == 'Settled') return l.status == SellerLoadStatus.completed;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_activeSegment == 0 ? 'Wholesale Buyers' : 'Seller Loads & Farmers'),
        actions: [
          IconButton(
            icon: Icon(_activeSegment == 0 ? Icons.person_add_alt_1_outlined : Icons.add_shopping_cart_outlined),
            tooltip: _activeSegment == 0 ? 'Add Buyer' : 'Create Seller Load',
            onPressed: () {
              if (_activeSegment == 0) {
                context.push('/customers/new');
              } else {
                CreateSellerLoadDialog.show(context);
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_fab',
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        icon: Icon(_activeSegment == 0 ? Icons.person_add : Icons.local_shipping),
        label: Text(
          _activeSegment == 0 ? 'Add Buyer' : 'Create Seller Load',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () {
          if (_activeSegment == 0) {
            context.push('/customers/new');
          } else {
            CreateSellerLoadDialog.show(context);
          }
        },
      ),
      body: Column(
        children: [
          // Segmented Switcher Bar (Wholesale Buyers vs Farmers & Inward Loads)
          Container(
            color: AppColors.cardSurface,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeSegment = 0),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSegment == 0 ? AppColors.primaryGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _activeSegment == 0 ? AppColors.primaryGreen : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 16, color: _activeSegment == 0 ? Colors.white : AppColors.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Wholesale Buyers (${buyers.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _activeSegment == 0 ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeSegment = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSegment == 1 ? AppColors.primaryGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _activeSegment == 1 ? AppColors.primaryGreen : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 16, color: _activeSegment == 1 ? Colors.white : AppColors.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Seller Loads (${loads.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _activeSegment == 1 ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Bar
          Container(
            color: AppColors.cardSurface,
            child: ResponsiveContainer(
              maxWidth: 1200,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: _activeSegment == 0
                          ? 'Search buyer by name, village, or phone...'
                          : 'Search by Load #, farmer, vehicle, or crop...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _activeSegment == 0
                          ? [
                              _FilterChip(
                                label: 'All Buyers (${buyers.length})',
                                selected: _buyerFilter == 'All',
                                onTap: () => setState(() => _buyerFilter = 'All'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'With Dues (${buyers.where((c) => c.openingBalance > 0).length})',
                                selected: _buyerFilter == 'Dues',
                                onTap: () => setState(() => _buyerFilter = 'Dues'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Settled (${buyers.where((c) => c.openingBalance == 0).length})',
                                selected: _buyerFilter == 'Settled',
                                onTap: () => setState(() => _buyerFilter = 'Settled'),
                              ),
                            ]
                          : [
                              _FilterChip(
                                label: 'All Loads (${loads.length})',
                                selected: _loadFilter == 'All',
                                onTap: () => setState(() => _loadFilter = 'All'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Arrived (${loads.where((l) => l.status == SellerLoadStatus.arrived).length})',
                                selected: _loadFilter == 'Arrived',
                                onTap: () => setState(() => _loadFilter = 'Arrived'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Partially Sold (${loads.where((l) => l.status == SellerLoadStatus.partiallySold).length})',
                                selected: _loadFilter == 'Partially Sold',
                                onTap: () => setState(() => _loadFilter = 'Partially Sold'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Settled (${loads.where((l) => l.status == SellerLoadStatus.completed).length})',
                                selected: _loadFilter == 'Settled',
                                onTap: () => setState(() => _loadFilter = 'Settled'),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Content List: Buyers OR Seller Loads
          Expanded(
            child: ResponsiveContainer(
              maxWidth: 1200,
              padding: EdgeInsets.zero,
              child: _activeSegment == 0
                  ? (filteredBuyers.isEmpty
                      ? EmptyStateView(
                          icon: Icons.storefront_outlined,
                          title: 'No Buyers Found',
                          description: _searchQuery.isNotEmpty
                              ? 'Try searching with a different name or phone number.'
                              : 'Add your first mandi wholesale buyer.',
                          buttonLabel: 'Add Buyer',
                          onButtonPressed: () => context.push('/customers/new'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filteredBuyers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final customer = filteredBuyers[index];
                            final balance = ref.watch(customerBalanceProvider(customer.id));

                            return _CustomerCard(
                              customer: customer,
                              balance: balance,
                              onTap: () => context.push('/customers/${customer.id}'),
                            );
                          },
                        ))
                  : (filteredLoads.isEmpty
                      ? EmptyStateView(
                          icon: Icons.local_shipping_outlined,
                          title: 'No Seller Loads Found',
                          description: _searchQuery.isNotEmpty
                              ? 'Try searching with a different Load # or farmer name.'
                              : 'Record your first inward lorry load from a farmer.',
                          buttonLabel: 'Create Seller Load',
                          onButtonPressed: () => CreateSellerLoadDialog.show(context),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filteredLoads.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final load = filteredLoads[index];
                            return _SellerLoadRowCard(load: load);
                          },
                        )),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerLoadRowCard extends StatelessWidget {
  final SellerLoad load;

  const _SellerLoadRowCard({required this.load});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.2),
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
                      color: AppColors.primaryGreenDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      load.loadNumber,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    load.commodity,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  load.statusLabel,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryGreenDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Farmer: ${load.sellerName} • ${load.village}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${load.totalBags} Bags', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
              Text('${load.grossWeight.toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
              Text('Lorry: ${load.vehicleNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Adv: ${CurrencyFormatter.format(load.advancePaidToSeller)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final double balance;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.customer,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.lightGreenSurface,
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: AppTypography.titleMedium.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.fromCustomerType(customer.customerType.name),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer.village,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(customer.phone, style: AppTypography.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(balance.abs()),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: balance > 0
                        ? AppColors.danger
                        : balance < 0
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                  ),
                ),
                Text(
                  balance > 0
                      ? 'Due'
                      : balance < 0
                          ? 'Advance'
                          : 'Settled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: balance > 0
                        ? AppColors.danger
                        : balance < 0
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryGreen,
      backgroundColor: AppColors.elevatedSurface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
