import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/currency_formatter.dart';

class ProduceTableItem {
  final TextEditingController nameCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController costRateCtrl;
  final TextEditingController sellRateCtrl;
  final TextEditingController labourChargeCtrl;

  ProduceTableItem({
    String name = '',
    String weight = '',
    String qty = '',
    String costRate = '',
    String sellRate = '',
    String labourCharge = '',
  })  : nameCtrl = TextEditingController(text: name),
        weightCtrl = TextEditingController(text: weight),
        qtyCtrl = TextEditingController(text: qty),
        costRateCtrl = TextEditingController(text: costRate),
        sellRateCtrl = TextEditingController(text: sellRate),
        labourChargeCtrl = TextEditingController(text: labourCharge);

  void dispose() {
    nameCtrl.dispose();
    weightCtrl.dispose();
    qtyCtrl.dispose();
    costRateCtrl.dispose();
    sellRateCtrl.dispose();
    labourChargeCtrl.dispose();
  }

  double get weight => double.tryParse(weightCtrl.text) ?? 0.0;
  double get quantity => double.tryParse(qtyCtrl.text) ?? 0.0;
  double get costRate => double.tryParse(costRateCtrl.text) ?? 0.0;
  double get sellRate => double.tryParse(sellRateCtrl.text) ?? 0.0;
  double get labourCharge => double.tryParse(labourChargeCtrl.text) ?? 0.0;

  double get goodsAmount {
    final basis = weight > 0 ? weight : quantity;
    return basis * sellRate;
  }

  double get lineTotal => goodsAmount + labourCharge;
}

class ProduceLinesTable extends StatelessWidget {
  final List<ProduceTableItem> items;
  final VoidCallback onAddLine;
  final ValueChanged<int> onRemoveLine;
  final VoidCallback onChanged;
  final String defaultProduceName;

  const ProduceLinesTable({
    super.key,
    required this.items,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onChanged,
    this.defaultProduceName = 'Produce',
  });

  double get totalBags => items.fold(0.0, (sum, i) => sum + i.quantity);
  double get totalWeight => items.fold(0.0, (sum, i) => sum + i.weight);
  double get totalGoodsSubtotal => items.fold(0.0, (sum, i) => sum + i.goodsAmount);
  double get totalLabour => items.fold(0.0, (sum, i) => sum + i.labourCharge);
  double get grandTotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  void _applyAutoHamali(double ratePerBag) {
    for (final item in items) {
      final bags = item.quantity;
      if (bags > 0) {
        item.labourChargeCtrl.text = (bags * ratePerBag).toStringAsFixed(0);
      }
    }
    onChanged();
  }

  void _clearHamali() {
    for (final item in items) {
      item.labourChargeCtrl.text = '0';
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Action Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.table_chart_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'DATABASE TABLE VIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length} Itemized ${items.length == 1 ? 'Row' : 'Rows'}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onAddLine,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('Add Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Scrollable Enterprise Database Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 680),
                  child: Column(
                    children: [
                      // Table Header Row
                      Container(
                        color: const Color(0xFF0F291E), // High-contrast Mandi Slate Navy
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            SizedBox(
                              width: 170,
                              child: Text('PRODUCE VARIETY / GRADE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                            ),
                            SizedBox(
                              width: 75,
                              child: Text('BAGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 95,
                              child: Text('WEIGHT (KG)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 95,
                              child: Text('RATE (₹/KG)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text('HAMALI (₹)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text('LINE TOTAL', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w900, fontSize: 11), textAlign: TextAlign.right),
                            ),
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Icon(Icons.more_vert, size: 16, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Itemized Table Rows
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isEven = index % 2 == 0;

                        return Container(
                          decoration: BoxDecoration(
                            color: isEven ? AppColors.cardSurface : const Color(0xFFF9FAFB),
                            border: const Border(
                              bottom: BorderSide(color: AppColors.border, width: 1.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // Row Index
                              SizedBox(
                                width: 36,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: AppColors.primaryGreenDark,
                                    ),
                                  ),
                                ),
                              ),

                              // Item / Variety Name
                              SizedBox(
                                width: 170,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _TableCellTextField(
                                    controller: item.nameCtrl,
                                    hint: 'Grade A Produce',
                                    onChanged: (_) => onChanged(),
                                    textAlign: TextAlign.start,
                                    isText: true,
                                  ),
                                ),
                              ),

                              // Bags Count
                              SizedBox(
                                width: 75,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _TableCellTextField(
                                    controller: item.qtyCtrl,
                                    hint: '40',
                                    onChanged: (_) => onChanged(),
                                    isNumeric: true,
                                  ),
                                ),
                              ),

                              // Weight (kg)
                              SizedBox(
                                width: 95,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _TableCellTextField(
                                    controller: item.weightCtrl,
                                    hint: '800',
                                    onChanged: (_) => onChanged(),
                                    isDecimal: true,
                                    suffixText: 'kg',
                                  ),
                                ),
                              ),

                              // Rate (₹/kg)
                              SizedBox(
                                width: 95,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _TableCellTextField(
                                    controller: item.sellRateCtrl,
                                    hint: '30',
                                    onChanged: (_) => onChanged(),
                                    isDecimal: true,
                                    prefixText: '₹',
                                  ),
                                ),
                              ),

                              // Hamali / Labour (₹)
                              SizedBox(
                                width: 90,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _TableCellTextField(
                                    controller: item.labourChargeCtrl,
                                    hint: '400',
                                    onChanged: (_) => onChanged(),
                                    isDecimal: true,
                                    prefixText: '₹',
                                  ),
                                ),
                              ),

                              // Line Total (Auto calculated)
                              SizedBox(
                                width: 100,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(item.lineTotal),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: AppColors.primaryGreenDark,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      if (item.labourCharge > 0)
                                        Text(
                                          'inc. ₹${item.labourChargeCtrl.text} hamali',
                                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Delete Action
                              SizedBox(
                                width: 40,
                                child: items.length > 1
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                        onPressed: () => onRemoveLine(index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Remove Row',
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Table Summary Footer Row
                      Container(
                        color: const Color(0xFFF1F5F9), // Light Slate
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 206,
                              child: Text(
                                'TOTAL SUMMARY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 75,
                              child: Text(
                                '${totalBags.toStringAsFixed(0)} bgs',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 95,
                              child: Text(
                                '${totalWeight.toStringAsFixed(0)} kg',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              width: 95,
                              child: Text(
                                'Avg Rate',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                CurrencyFormatter.format(totalLabour),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                CurrencyFormatter.format(grandTotal),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreenDark,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scroll Guidance / Quick Hamali Presets Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.swipe, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Swipe sideways to view all columns',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          _QuickTableChip('Auto Hamali (₹10/bag)', () => _applyAutoHamali(10)),
                          const SizedBox(width: 6),
                          _QuickTableChip('₹0 Hamali', _clearHamali),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableCellTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool isNumeric;
  final bool isDecimal;
  final bool isText;
  final TextAlign textAlign;
  final String? prefixText;
  final String? suffixText;

  const _TableCellTextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.isNumeric = false,
    this.isDecimal = false,
    this.isText = false,
    this.textAlign = TextAlign.center,
    this.prefixText,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        textAlign: textAlign,
        keyboardType: isNumeric
            ? TextInputType.number
            : (isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
          prefixText: prefixText != null ? '$prefixText ' : null,
          prefixStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          suffixText: suffixText != null ? ' $suffixText' : null,
          suffixStyle: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _QuickTableChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTableChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.lightGreenSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreenDark),
        ),
      ),
    );
  }
}
