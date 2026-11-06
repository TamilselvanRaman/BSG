import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/app_state.dart';
import '../../data/models/goods_entry.dart';

class GoodsEntriesListScreen extends ConsumerStatefulWidget {
  const GoodsEntriesListScreen({super.key});

  @override
  ConsumerState<GoodsEntriesListScreen> createState() => _GoodsEntriesListScreenState();
}

class _GoodsEntriesListScreenState extends ConsumerState<GoodsEntriesListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Confirmed', 'Billed', 'Draft'

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(goodsEntriesProvider);
    final customers = ref.watch(customersProvider);

    final filtered = entries.where((e) {
      final cust = customers.cast<dynamic>().firstWhere(
        (c) => c.id == e.customerId,
        orElse: () => null,
      );
      final custName = cust?.name.toLowerCase() ?? '';

      final matchesSearch = e.entryNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.lotNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.goodsName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          custName.contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Confirmed') return e.status == GoodsEntryStatus.confirmed;
      if (_selectedFilter == 'Billed') return e.status == GoodsEntryStatus.billed;
      if (_selectedFilter == 'Draft') return e.status == GoodsEntryStatus.draft;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goods Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'New Goods Entry',
            onPressed: () => context.push('/goods-entries/new'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'goods_entries_fab',
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/goods-entries/new'),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: AppColors.cardSurface,
            child: ResponsiveContainer(
              maxWidth: 1200,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search entry, lot, goods or buyer...',
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
                      children: [
                        _FilterTab(
                          label: 'All (${entries.length})',
                          selected: _selectedFilter == 'All',
                          onTap: () => setState(() => _selectedFilter = 'All'),
                        ),
                        const SizedBox(width: 8),
                        _FilterTab(
                          label: 'Ready for Bill (${entries.where((e) => e.status == GoodsEntryStatus.confirmed).length})',
                          selected: _selectedFilter == 'Confirmed',
                          onTap: () => setState(() => _selectedFilter = 'Confirmed'),
                        ),
                        const SizedBox(width: 8),
                        _FilterTab(
                          label: 'Billed (${entries.where((e) => e.status == GoodsEntryStatus.billed).length})',
                          selected: _selectedFilter == 'Billed',
                          onTap: () => setState(() => _selectedFilter = 'Billed'),
                        ),
                        const SizedBox(width: 8),
                        _FilterTab(
                          label: 'Draft (${entries.where((e) => e.status == GoodsEntryStatus.draft).length})',
                          selected: _selectedFilter == 'Draft',
                          onTap: () => setState(() => _selectedFilter = 'Draft'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Entries List / Grid
          Expanded(
            child: ResponsiveContainer(
              maxWidth: 1200,
              padding: EdgeInsets.zero,
              child: filtered.isEmpty
                  ? EmptyStateView(
                      icon: Icons.inventory_2_outlined,
                      title: 'No Goods Entries Found',
                      description: _searchQuery.isNotEmpty
                          ? 'Try searching with a different keyword.'
                          : 'Record arrival of new goods lots from farmers or sellers.',
                      buttonLabel: 'Record New Entry',
                      onButtonPressed: () => context.push('/goods-entries/new'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isMultiCol = constraints.maxWidth >= 768;
                        if (isMultiCol) {
                          final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              mainAxisExtent: 146,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final entry = filtered[index];
                              final customer = customers.cast<dynamic>().firstWhere(
                                (c) => c.id == entry.customerId,
                                orElse: () => null,
                              );
                              return _buildGoodsEntryCard(entry, customer);
                            },
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            final customer = customers.cast<dynamic>().firstWhere(
                              (c) => c.id == entry.customerId,
                              orElse: () => null,
                            );
                            return _buildGoodsEntryCard(entry, customer);
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodsEntryCard(GoodsEntry entry, dynamic customer) {
    return InkWell(
      onTap: () => context.push('/goods-entries/${entry.id}'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(entry.entryNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.status == GoodsEntryStatus.billed
                            ? AppColors.lightGreenSurface
                            : entry.status == GoodsEntryStatus.confirmed
                                ? AppColors.pendingBg
                                : AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.status == GoodsEntryStatus.billed
                            ? 'BILLED'
                            : entry.status == GoodsEntryStatus.confirmed
                                ? 'READY TO BILL'
                                : 'DRAFT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: entry.status == GoodsEntryStatus.billed
                              ? AppColors.primaryGreen
                              : entry.status == GoodsEntryStatus.confirmed
                                  ? AppColors.pending
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(DateFormatter.format(entry.entryDate), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      _getProduceEmoji(entry.goodsName),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer?.name ?? 'Unknown Buyer',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.goodsName} • Lot: ${entry.lotNumber}${entry.vehicleNumber.isNotEmpty ? ' • ${entry.vehicleNumber}' : ''}',
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.totalWeight.toStringAsFixed(0)} kg (${entry.goodsCount} bags)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
                Text(
                  CurrencyFormatter.format(entry.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
              ],
            ),
            if (entry.initialPaymentAmount > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.initialPaymentBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 13, color: AppColors.initialPaymentBadge),
                    const SizedBox(width: 4),
                    Text(
                      'Initial Payment: ${CurrencyFormatter.format(entry.initialPaymentAmount)} (${entry.initialPaymentMode})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.initialPaymentBadge),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProduceEmoji(String goodsName) {
    final lower = goodsName.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion') || lower.contains('shallot')) return '🧅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('chilli') || lower.contains('chili')) return '🌶️';
    if (lower.contains('cabbage') || lower.contains('cauliflower')) return '🥬';
    if (lower.contains('ginger')) return '🫚';
    if (lower.contains('carrot')) return '🥕';
    if (lower.contains('garlic')) return '🧄';
    if (lower.contains('drumstick') || lower.contains('moringa')) return '🌿';
    if (lower.contains('capsicum') || lower.contains('pepper')) return '🫑';
    if (lower.contains('beetroot')) return '🍠';
    return '📦';
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.selected, required this.onTap});

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
    );
  }
}
