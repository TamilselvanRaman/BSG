import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';

enum PricingRateBasis {
  perKg,
  perBag,
  fixedLot,
}

class RatePricingStep extends StatelessWidget {
  final PricingRateBasis rateBasis;
  final ValueChanged<PricingRateBasis> onRateBasisChanged;
  final TextEditingController purchaseRateController;
  final TextEditingController sellingRateController;
  final TextEditingController discountController;
  final double netWeight;
  final int totalPackages;
  final VoidCallback onChanged;
  final bool isEmbedded;

  const RatePricingStep({
    super.key,
    required this.rateBasis,
    required this.onRateBasisChanged,
    required this.purchaseRateController,
    required this.sellingRateController,
    required this.discountController,
    required this.netWeight,
    required this.totalPackages,
    required this.onChanged,
    this.isEmbedded = false,
  });

  double get purchaseRate => double.tryParse(purchaseRateController.text) ?? 0.0;
  double get sellingRate => double.tryParse(sellingRateController.text) ?? 0.0;
  double get discountAmount => double.tryParse(discountController.text) ?? 0.0;

  double get grossGoodsTotal {
    switch (rateBasis) {
      case PricingRateBasis.perKg:
        return netWeight * purchaseRate;
      case PricingRateBasis.perBag:
        return totalPackages * purchaseRate;
      case PricingRateBasis.fixedLot:
        return purchaseRate;
    }
  }

  double get netGoodsTotal => (grossGoodsTotal - discountAmount).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Rate Basis Selector
          Text(
            'Select Rate Basis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildBasisCard(
                  title: 'Rate / Kg',
                  subtitle: 'Calculated on Net Weight',
                  isSelected: rateBasis == PricingRateBasis.perKg,
                  onTap: () {
                    onRateBasisChanged(PricingRateBasis.perKg);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBasisCard(
                  title: 'Rate / Bag',
                  subtitle: 'Calculated on Bag Count',
                  isSelected: rateBasis == PricingRateBasis.perBag,
                  onTap: () {
                    onRateBasisChanged(PricingRateBasis.perBag);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBasisCard(
                  title: 'Fixed Lot',
                  subtitle: 'Lump-sum Amount',
                  isSelected: rateBasis == PricingRateBasis.fixedLot,
                  onTap: () {
                    onRateBasisChanged(PricingRateBasis.fixedLot);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Inputs Card
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
                  'Pricing & Rate Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                // Purchase Rate
                Text(
                  'Purchase Cost Rate (₹ per ${_getBasisUnitName()})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: purchaseRateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                    hintText: 'e.g. 35.00',
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: 14),

                // Selling Rate (Target / Benchmark)
                Text(
                  'Expected Selling Rate (₹ per ${_getBasisUnitName()}) [Optional]',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: sellingRateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged(),
                  style: TextStyle(fontSize: 14, color: theme.text),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(fontSize: 14, color: theme.text),
                    hintText: 'e.g. 42.00',
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: 14),

                // Trade Discount or Allowance
                Text(
                  'Consignment Discount / Allowance (₹)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged(),
                  style: TextStyle(fontSize: 14, color: theme.text),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(fontSize: 14, color: theme.text),
                    hintText: '0.00',
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Highlighted Final Goods Value Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.08),
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
                    Text(
                      'Billable Quantity:',
                      style: TextStyle(fontSize: 13, color: theme.textSecondary),
                    ),
                    Text(
                      _getBillableQuantityLabel(),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gross Goods Total:',
                      style: TextStyle(fontSize: 13, color: theme.textSecondary),
                    ),
                    Text(
                      AppFormatters.currency(grossGoodsTotal),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                    ),
                  ],
                ),
                if (discountAmount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount Applied:',
                        style: TextStyle(fontSize: 13, color: theme.error),
                      ),
                      Text(
                        '- ${AppFormatters.currency(discountAmount)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.error),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Divider(color: theme.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Goods Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.text,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(netGoodsTotal),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  String _getBasisUnitName() {
    switch (rateBasis) {
      case PricingRateBasis.perKg:
        return 'Kg';
      case PricingRateBasis.perBag:
        return 'Bag';
      case PricingRateBasis.fixedLot:
        return 'Lot';
    }
  }

  String _getBillableQuantityLabel() {
    switch (rateBasis) {
      case PricingRateBasis.perKg:
        return '${netWeight.toStringAsFixed(1)} Kg';
      case PricingRateBasis.perBag:
        return '$totalPackages Bags';
      case PricingRateBasis.fixedLot:
        return '1 Fixed Lot';
    }
  }

  Widget _buildBasisCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.1) : theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? theme.primary : theme.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

