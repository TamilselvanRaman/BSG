import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/lot_model.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_image_view.dart';

class LotDetailsScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotDetailsScreen({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailsScreen> createState() => _LotDetailsScreenState();
}

class _LotDetailsScreenState extends ConsumerState<LotDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final lot = ref.watch(appRepositoryProvider).getLot(widget.lotId);
    final allProducts = ref.watch(appRepositoryProvider).products;

    if (lot == null) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          title: Text('Lot Details', style: TextStyle(color: theme.text)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.text),
            onPressed: () => context.pop(),
          ),
        ),
        body: const AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Lot Not Found',
          description: 'The requested lot record does not exist or was deleted.',
        ),
      );
    }

    final matchedProduct = allProducts.firstWhere(
      (p) => p.name.toLowerCase() == lot.productName.toLowerCase(),
      orElse: () => allProducts.first,
    );

    // Associated sales bills
    final bills = ref.watch(billsProvider).where((b) => b.lotId == lot.id && !b.isCancelled).toList();
    final soldQuantity = lot.initialQuantity - lot.remainingQuantity;
    final soldPercentage = lot.initialQuantity > 0 ? (soldQuantity / lot.initialQuantity).clamp(0.0, 1.0) : 0.0;

    final statusColor = lot.isAvailable ? theme.success : theme.textMuted;
    final statusLabel = lot.isAvailable
        ? (lot.remainingQuantity < lot.initialQuantity ? 'PARTIALLY SOLD' : 'IN STOCK')
        : 'FULLY SOLD';

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          lot.lotNumber,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.text),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.text),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.error),
            tooltip: 'Delete Lot',
            onPressed: () => _confirmDeleteLot(context, lot, theme),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Overview Card with Real Crop Thumbnail
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: theme.primary, width: 2),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: ProductImageView(
                              assetPath: lot.items.isNotEmpty ? lot.items.first.assetPath : matchedProduct.assetPath,
                              imageUrl: lot.items.isNotEmpty ? lot.items.first.imageUrl : matchedProduct.imageUrl,
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lot.productName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: theme.text,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                            const SizedBox(height: 4),
                            Text(
                              'Supplier: ${lot.supplierName}',
                              style: TextStyle(fontSize: 13, color: theme.textSecondary),
                            ),
                            Text(
                              'Inward: ${AppFormatters.date(lot.date)}',
                              style: TextStyle(fontSize: 11, color: theme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Stock Position & Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock & Inventory Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Stock', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.quantity(lot.remainingQuantity, lot.unit),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.primary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Sold Stock', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.quantity(soldQuantity, lot.unit),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Initial Stock', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.quantity(lot.initialQuantity, lot.unit),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: soldPercentage,
                      backgroundColor: theme.accent,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(soldPercentage * 100).toStringAsFixed(1)}% Sold • ${lot.goodsCount} Total Bags',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Purchase Cost & Inward Mandi Charges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase Valuation & Mandi Charges',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Cost Rate', '${AppFormatters.currency(lot.costRate)} / ${lot.unit}', theme),
                  _buildDetailRow('Goods Cost', AppFormatters.currency(lot.initialQuantity * lot.costRate), theme),
                  if (lot.labourCharge > 0)
                    _buildDetailRow('Labour / Hamali Charges', AppFormatters.currency(lot.labourCharge), theme),
                  if (lot.transportCharge > 0)
                    _buildDetailRow('Transport / Freight', AppFormatters.currency(lot.transportCharge), theme),
                  if (lot.otherCharges > 0)
                    _buildDetailRow('Mandi & Other Charges', AppFormatters.currency(lot.otherCharges), theme),
                  Divider(color: theme.border, height: 16),
                  _buildDetailRow('Total Inward Cost', AppFormatters.currency(lot.totalInitialCost), theme, isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Logistics & Entry Specifications
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consignment & Vehicle Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Vehicle / Lorry Number', lot.vehicleNumber ?? 'N/A', theme),
                  _buildDetailRow('Inward Entry Number', lot.entryNumber ?? 'N/A', theme),
                  _buildDetailRow('Total Package Count', '${lot.goodsCount} Bags', theme),
                  _buildDetailRow('Consignment Net Weight', '${lot.initialWeight.toStringAsFixed(1)} Kg', theme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Sales Bills linked to this lot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Bills from this Lot',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                ),
                Text(
                  '${bills.length} Bills',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (bills.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Center(
                  child: Text(
                    'No outward sales bills created yet from this inward lot.',
                    style: TextStyle(fontSize: 12, color: theme.textMuted),
                  ),
                ),
              )
            else
              ...bills.map((b) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.billNumber, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text)),
                            Text(b.customerName, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                            Text(
                              'Sold: ${AppFormatters.quantity(b.quantity, b.unit)} @ ${AppFormatters.currency(b.sellRate)}',
                              style: TextStyle(fontSize: 11, color: theme.textMuted),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(AppFormatters.currency(b.totalAmount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary)),
                            Text(AppFormatters.date(b.date), style: TextStyle(fontSize: 11, color: theme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  )),

            const SizedBox(height: 80), // Extra space for sticky bottom bar
          ],
        ),
      ),

      // Sticky Bottom Action Area for quick billing
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: lot.isAvailable
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/bills/lot-billing?lotId=${lot.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.scale_rounded, size: 18),
                        label: const Text('Lot-Based Bill', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/bills/create-cash?lotId=${lot.id}'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.text,
                          side: BorderSide(color: theme.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.payments_outlined, size: 16),
                        label: const Text('Quick Cash', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'Lot Stock Fully Disposed',
                    style: TextStyle(fontWeight: FontWeight.w700, color: theme.textSecondary),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppThemeColors theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? theme.text : theme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? theme.primary : theme.text,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLot(BuildContext context, Lot lot, AppThemeColors theme) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nav = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Delete Lot ${lot.lotNumber}?', style: TextStyle(color: theme.text, fontWeight: FontWeight.w700)),
          content: Text(
            'Are you sure you want to delete this lot? All stock records will be removed.',
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
                  nav.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Lot ${lot.lotNumber} deleted successfully'),
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
}
