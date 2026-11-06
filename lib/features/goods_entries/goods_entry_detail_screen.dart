import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/app_button.dart';
import '../../data/app_state.dart';
import '../../data/models/goods_entry.dart';

class GoodsEntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const GoodsEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(goodsEntriesProvider);
    final entry = entries.cast<GoodsEntry?>().firstWhere(
      (e) => e?.id == entryId,
      orElse: () => null,
    );

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goods Entry Details')),
        body: const Center(child: Text('Goods Entry not found')),
      );
    }

    final customers = ref.watch(customersProvider);
    final customer = customers.cast<dynamic>().firstWhere(
      (c) => c.id == entry.customerId,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(entry.entryNumber),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: entry.status == GoodsEntryStatus.billed
                  ? AppColors.lightGreenSurface
                  : entry.status == GoodsEntryStatus.confirmed
                      ? AppColors.pendingBg
                      : AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.status == GoodsEntryStatus.billed
                  ? 'BILLED'
                  : entry.status == GoodsEntryStatus.confirmed
                      ? 'READY TO BILL'
                      : 'DRAFT',
              style: TextStyle(
                fontSize: 12,
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
      body: ResponsiveContainer(
        maxWidth: 880,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Summary Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Buyer Name', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            customer?.name ?? 'Unknown Buyer',
                            style: AppTypography.titleMedium,
                          ),
                          if (customer != null)
                            Text(customer.village, style: AppTypography.bodySmall),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Entry Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(DateFormatter.format(entry.entryDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(child: _metaCol('Lot Number', entry.lotNumber)),
                      Expanded(child: _metaCol('Bags Count', '${entry.goodsCount} bags')),
                      Expanded(child: _metaCol('Commodity', entry.goodsName)),
                    ],
                  ),
                  if (entry.vehicleNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _metaCol('Vehicle Number', entry.vehicleNumber),
                  ],
                  if (entry.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _metaCol('Remarks', entry.notes),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Product Items Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Lines & Quantities', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2.5),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                        children: [
                          Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                          Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Weight', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                          Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                          Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                        ],
                      ),
                      ...entry.items.map((item) {
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${item.weight.toStringAsFixed(0)} kg', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('₹${item.sellRate.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(CurrencyFormatter.format(item.lineTotal), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                          ],
                        );
                      }),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Billable Weight: ${entry.totalWeight.toStringAsFixed(0)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Goods: ${CurrencyFormatter.format(entry.goodsSubtotal)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (entry.totalLabourCharge > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Labour / Hamali Charges:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(CurrencyFormatter.format(entry.totalLabourCharge), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimated Value:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(
                        CurrencyFormatter.format(entry.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Initial Payment Received Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.lightGreenSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primaryGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Initial Payment Received',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryGreenDark),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(entry.initialPaymentAmount),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Mode: ${entry.initialPaymentMode}${entry.initialPaymentRef.isNotEmpty ? ' • Ref: ${entry.initialPaymentRef}' : ''}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  if (entry.initialPaymentNotes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Notes: ${entry.initialPaymentNotes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Generate Bill Action
            if (entry.status != GoodsEntryStatus.billed) ...[
              AppButton(
                label: 'Generate Bill from This Entry',
                onPressed: () {
                  context.push('/bills/new?entryId=${entry.id}&customerId=${entry.customerId}');
                },
                icon: Icons.receipt_long,
                width: double.infinity,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    ),
  );
}

  Widget _metaCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
