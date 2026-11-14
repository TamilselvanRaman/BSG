import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/lot_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_image_view.dart';

class LotsListScreen extends ConsumerStatefulWidget {
  const LotsListScreen({super.key});

  @override
  ConsumerState<LotsListScreen> createState() => _LotsListScreenState();
}

class _LotsListScreenState extends ConsumerState<LotsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'available', 'soldOut'
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'qty_desc', 'value_desc'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allLots = ref.watch(lotsProvider);
    final allProducts = ref.watch(appRepositoryProvider).products;

    // Filter lots
    List<Lot> filtered = allLots.where((lot) {
      if (_selectedFilter == 'available' && !lot.isAvailable) return false;
      if (_selectedFilter == 'soldOut' && lot.isAvailable) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesLotNo = lot.lotNumber.toLowerCase().contains(query);
        final matchesProduct = lot.productName.toLowerCase().contains(query);
        final matchesSupplier = lot.supplierName.toLowerCase().contains(query);
        final matchesVehicle = (lot.vehicleNumber ?? '').toLowerCase().contains(query);
        final matchesEntry = (lot.entryNumber ?? '').toLowerCase().contains(query);
        if (!matchesLotNo && !matchesProduct && !matchesSupplier && !matchesVehicle && !matchesEntry) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort lots
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return a.date.compareTo(b.date);
        case 'qty_desc':
          return b.remainingQuantity.compareTo(a.remainingQuantity);
        case 'value_desc':
          return b.totalInitialCost.compareTo(a.totalInitialCost);
        case 'date_desc':
        default:
          return b.date.compareTo(a.date);
      }
    });

    final totalActiveStock = allLots.where((l) => l.isAvailable).fold<double>(0.0, (acc, l) => acc + l.remainingQuantity);
    final totalActiveLots = allLots.where((l) => l.isAvailable).length;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Lot Inventory & Procurement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.text,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_suggest_rounded, color: theme.text),
            tooltip: 'Lot Configuration',
            onPressed: () => context.push('/lots/configuration'),
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: theme.text),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterBottomSheet(context, theme),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: theme.primary, size: 28),
            tooltip: 'Create New Lot',
            onPressed: () => context.push('/lots/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Inventory Summary Metric Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Lots In Stock',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalActiveLots Lots',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.text),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: theme.border),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Unsold Stock',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalActiveStock.toStringAsFixed(0)} Kg',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar & Filter Chips
          Container(
            color: theme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, size: 20, color: theme.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          style: TextStyle(fontSize: 13, color: theme.text),
                          decoration: InputDecoration(
                            hintText: 'Search lot #, crop, supplier, lorry #...',
                            hintStyle: TextStyle(fontSize: 13, color: theme.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          color: theme.textMuted,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Status Pills
                Row(
                  children: [
                    _buildStatusChip('All Lots (${allLots.length})', 'all', theme),
                    const SizedBox(width: 8),
                    _buildStatusChip('Available Stock ($totalActiveLots)', 'available', theme),
                    const SizedBox(width: 8),
                    _buildStatusChip('Fully Sold', 'soldOut', theme),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.border),

          // Lots List
          Expanded(
            child: filtered.isEmpty
                ? AppEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Inward Lots Found',
                    description: _searchQuery.isNotEmpty
                        ? 'No lots match "$_searchQuery". Check your search or clear filters.'
                        : 'No lot entries found in this category. Click below to add your first lot.',
                    actionText: 'Create New Lot',
                    onAction: () => context.push('/lots/create'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lot = filtered[index];
                      // Find product matching name to get real thumbnail asset
                      final matchedProduct = allProducts.firstWhere(
                        (p) => p.name.toLowerCase() == lot.productName.toLowerCase(),
                        orElse: () => allProducts.first,
                      );
                      return _buildLotCard(context, lot, matchedProduct, theme);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lots/create'),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('New Lot', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStatusChip(String label, String key, AppThemeColors theme) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.accent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.text,
          ),
        ),
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, Lot lot, Product matchedProduct, AppThemeColors theme) {
    final statusColor = lot.isAvailable ? theme.success : theme.textMuted;
    final statusLabel = lot.isAvailable
        ? (lot.remainingQuantity < lot.initialQuantity ? 'PARTIALLY SOLD' : 'IN STOCK')
        : 'FULLY SOLD';

    return GestureDetector(
      onTap: () => context.push('/lots/${lot.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Product Thumbnail + Lot No + Status Badge + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Product Thumbnail
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                  child: Center(
                    child: ClipOval(
                      child: ProductImageView(
                        assetPath: lot.items.isNotEmpty ? lot.items.first.assetPath : matchedProduct.assetPath,
                        imageUrl: lot.items.isNotEmpty ? lot.items.first.imageUrl : matchedProduct.imageUrl,
                        size: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Lot Number & Product Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lot.lotNumber,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: theme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lot.productName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Farmer: ${lot.supplierName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Logistics / Vehicle & Entry info
            if (lot.vehicleNumber != null || lot.entryNumber != null) ...[
              Row(
                children: [
                  if (lot.vehicleNumber != null) ...[
                    Icon(Icons.local_shipping_outlined, size: 14, color: theme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      lot.vehicleNumber!,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (lot.entryNumber != null) ...[
                    Icon(Icons.tag, size: 14, color: theme.textMuted),
                    const SizedBox(width: 2),
                    Text(
                      lot.entryNumber!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    AppFormatters.date(lot.date),
                    style: TextStyle(fontSize: 11, color: theme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Stock & Valuation Metrics Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Available Stock', style: TextStyle(fontSize: 10, color: theme.textMuted)),
                      Text(
                        '${lot.remainingQuantity.toStringAsFixed(1)} ${lot.unit}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.text),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Packages', style: TextStyle(fontSize: 10, color: theme.textMuted)),
                      Text(
                        '${lot.goodsCount} Bags',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Purchase Value', style: TextStyle(fontSize: 10, color: theme.textMuted)),
                      Text(
                        AppFormatters.currency(lot.totalInitialCost),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card Quick Actions Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quick Bill creation
                if (lot.isAvailable)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.push('/bills/lot-billing?lotId=${lot.id}'),
                        icon: const Icon(Icons.scale, size: 14),
                        label: const Text('Lot Bill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/bills/create-cash?lotId=${lot.id}'),
                        icon: const Icon(Icons.payments_outlined, size: 14),
                        label: const Text('Cash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textSecondary,
                          side: BorderSide(color: theme.border),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'No stock remaining for billing',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.textMuted),
                  ),

                // View Details Icon Link
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: theme.error),
                      tooltip: 'Delete Lot',
                      onPressed: () => _confirmDeleteLot(context, lot, theme),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 14, color: theme.primary),
                      tooltip: 'View Details',
                      onPressed: () => context.push('/lots/${lot.id}'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLot(BuildContext context, Lot lot, AppThemeColors theme) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Delete Lot ${lot.lotNumber}?', style: TextStyle(color: theme.text, fontWeight: FontWeight.w700)),
          content: Text(
            'Are you sure you want to delete this inward lot for ${lot.productName}? This action cannot be undone.',
            style: TextStyle(color: theme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(appRepositoryProvider).deleteLot(lot.id);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Lot ${lot.lotNumber} deleted'),
                      backgroundColor: theme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.error, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, AppThemeColors theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort Lots',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: theme.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Sort By', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortPill('Newest First', 'date_desc', setModalState, theme),
                      _buildSortPill('Oldest First', 'date_asc', setModalState, theme),
                      _buildSortPill('Highest Stock', 'qty_desc', setModalState, theme),
                      _buildSortPill('Highest Value', 'value_desc', setModalState, theme),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortPill(String label, String value, StateSetter setModalState, AppThemeColors theme) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setModalState(() => _sortBy = value);
        setState(() => _sortBy = value);
      },
      selectedColor: theme.primary,
      backgroundColor: theme.accent,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : theme.text,
      ),
    );
  }
}
