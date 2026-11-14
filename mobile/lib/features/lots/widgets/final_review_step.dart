import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../catalogue/widgets/product_image_view.dart';
import 'bags_goods_step.dart';
import 'expenses_charges_step.dart';
import 'payment_details_step.dart';
import 'rate_pricing_step.dart';
import 'weight_details_step.dart';

class FinalReviewStep extends StatelessWidget {
  final Product? selectedProduct;
  final String supplierName;
  final String? entryNumber;
  final String? vehicleNumber;
  final DateTime lotDate;
  final String lotNumber;
  final List<BagEntryItem> bagEntries;
  final WeightEntryMode weightMode;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final PricingRateBasis rateBasis;
  final double purchaseRate;
  final double sellingRate;
  final double discountAmount;
  final double netGoodsAmount;
  final double labourCharge;
  final double transportCharge;
  final double sangamCharge;
  final double mamoolCharge;
  final double otherCharges;
  final List<CustomLotExpense> customExpenses;
  final double totalInwardExpenses;
  final double advancePaid;
  final double remainingRent;
  final double paidAmount;
  final PaymentMode paymentMode;
  final String paymentReference;
  final String notes;
  final Function(int) onEditSection;
  final bool isEmbedded;

  const FinalReviewStep({
    super.key,
    required this.selectedProduct,
    required this.supplierName,
    required this.entryNumber,
    required this.vehicleNumber,
    required this.lotDate,
    required this.lotNumber,
    required this.bagEntries,
    required this.weightMode,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.rateBasis,
    required this.purchaseRate,
    required this.sellingRate,
    required this.discountAmount,
    required this.netGoodsAmount,
    required this.labourCharge,
    required this.transportCharge,
    required this.sangamCharge,
    required this.mamoolCharge,
    required this.otherCharges,
    required this.customExpenses,
    required this.totalInwardExpenses,
    required this.advancePaid,
    required this.remainingRent,
    required this.paidAmount,
    required this.paymentMode,
    required this.paymentReference,
    required this.notes,
    required this.onEditSection,
    this.isEmbedded = false,
  });

  double get grandTotal => netGoodsAmount + totalInwardExpenses;
  double get totalPaidSoFar => advancePaid + paidAmount;
  double get balanceDue => (grandTotal - totalPaidSoFar).clamp(0.0, double.infinity);
  int get totalPackages => bagEntries.fold<int>(0, (acc, item) => acc + item.count);

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Grand Total Highlight Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL LOT INWARD VALUE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.currency(grandTotal),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lotNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid: ${AppFormatters.currency(totalPaidSoFar)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Text(
                        'Due: ${AppFormatters.currency(balanceDue)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: balanceDue > 0 ? Colors.amberAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 1. Product Summary Card
          _buildReviewCard(
            title: '1. Product & Crop Details',
            stepIndex: 0,
            theme: theme,
            content: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: ProductImageView(
                      assetPath: selectedProduct?.assetPath,
                      imageUrl: selectedProduct?.imageUrl,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProduct?.name ?? 'Standard Crop',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                      Text(
                        'Category: ${selectedProduct?.categoryName ?? 'Crop'} • Default Unit: ${selectedProduct?.defaultUnit ?? 'Kg'}',
                        style: TextStyle(fontSize: 11, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Lot & Supplier Information
          _buildReviewCard(
            title: '2. Lot & Supplier Information',
            stepIndex: 1,
            theme: theme,
            content: Column(
              children: [
                _buildRow('Supplier / Farmer', supplierName, theme),
                _buildRow('Entry Number', entryNumber?.isNotEmpty == true ? entryNumber! : 'N/A', theme),
                _buildRow('Vehicle Number', vehicleNumber?.isNotEmpty == true ? vehicleNumber! : 'N/A', theme),
                _buildRow('Inward Date', AppFormatters.date(lotDate), theme),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Bags & Goods Details
          _buildReviewCard(
            title: '3. Bags & Package Breakdown',
            stepIndex: 2,
            theme: theme,
            content: Column(
              children: [
                _buildRow('Total Packages', '$totalPackages Bags / Packages', theme, isBold: true),
                ...bagEntries.asMap().entries.map((e) {
                  final item = e.value;
                  return _buildRow(
                    'Entry #${e.key + 1} (${item.titleController.text.isNotEmpty ? item.titleController.text : 'Lot'})',
                    '${item.count} ${item.unit}',
                    theme,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Weight Breakdown
          _buildReviewCard(
            title: '4. Weight Specifications',
            stepIndex: 3,
            theme: theme,
            content: Column(
              children: [
                _buildRow(
                  'Weighing Mode',
                  weightMode == WeightEntryMode.fullWeighbridge ? 'Weighbridge Mode' : 'Direct Net Weight',
                  theme,
                ),
                if (weightMode == WeightEntryMode.fullWeighbridge) ...[
                  _buildRow('Gross Weight', '${grossWeight.toStringAsFixed(1)} Kg', theme),
                  _buildRow('Tare Weight', '${tareWeight.toStringAsFixed(1)} Kg', theme),
                ],
                _buildRow('Net Inward Weight', '${netWeight.toStringAsFixed(1)} Kg', theme, isBold: true),
                if (totalPackages > 0 && netWeight > 0)
                  _buildRow('Avg Weight per Bag', '${(netWeight / totalPackages).toStringAsFixed(2)} Kg/Bag', theme),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 5. Rate & Goods Valuation
          _buildReviewCard(
            title: '5. Rate & Goods Pricing',
            stepIndex: 4,
            theme: theme,
            content: Column(
              children: [
                _buildRow('Pricing Basis', rateBasis == PricingRateBasis.perKg ? 'Rate / Kg' : rateBasis == PricingRateBasis.perBag ? 'Rate / Bag' : 'Fixed Lot', theme),
                _buildRow('Purchase Rate', '${AppFormatters.currency(purchaseRate)} / unit', theme),
                if (sellingRate > 0)
                  _buildRow('Benchmark Selling Rate', '${AppFormatters.currency(sellingRate)} / unit', theme),
                if (discountAmount > 0)
                  _buildRow('Discount / Allowance', '- ${AppFormatters.currency(discountAmount)}', theme),
                _buildRow('Net Goods Value', AppFormatters.currency(netGoodsAmount), theme, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 6. Expenses & Mandi Charges
          _buildReviewCard(
            title: '6. Inward Mandi Charges',
            stepIndex: 5,
            theme: theme,
            content: Column(
              children: [
                if (labourCharge > 0) _buildRow('Labour / Hamali', AppFormatters.currency(labourCharge), theme),
                if (transportCharge > 0) _buildRow('Transport / Freight', AppFormatters.currency(transportCharge), theme),
                if (sangamCharge > 0) _buildRow('Sangam / Mandi Cess', AppFormatters.currency(sangamCharge), theme),
                if (mamoolCharge > 0) _buildRow('Mamool / Weighing', AppFormatters.currency(mamoolCharge), theme),
                if (otherCharges > 0) _buildRow('Other Inward Charges', AppFormatters.currency(otherCharges), theme),
                ...customExpenses.map((exp) {
                  final amt = exp.calculateAmount(totalPackages, netWeight);
                  return _buildRow(exp.name, AppFormatters.currency(amt), theme);
                }),
                Divider(color: theme.border, height: 16),
                _buildRow('Total Inward Expenses', AppFormatters.currency(totalInwardExpenses), theme, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 7. Payment & Supplier Settlement
          _buildReviewCard(
            title: '7. Payment & Settlement Status',
            stepIndex: 6,
            theme: theme,
            content: Column(
              children: [
                _buildRow('Payment Mode', paymentMode.name.toUpperCase(), theme),
                if (advancePaid > 0) _buildRow('Advance Paid', AppFormatters.currency(advancePaid), theme),
                if (paidAmount > 0) _buildRow('Paid at Inward', AppFormatters.currency(paidAmount), theme),
                if (paymentReference.isNotEmpty) _buildRow('Payment Ref / Cheque #', paymentReference, theme),
                _buildRow('Total Paid', AppFormatters.currency(totalPaidSoFar), theme),
                _buildRow('Outstanding Balance Due', AppFormatters.currency(balanceDue), theme, isBold: true),
                if (notes.isNotEmpty) _buildRow('Notes', notes, theme),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      );

    if (isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildReviewCard({
    required String title,
    required int stepIndex,
    required AppThemeColors theme,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              GestureDetector(
                onTap: () => onEditSection(stepIndex),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 12, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, AppThemeColors theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
}

