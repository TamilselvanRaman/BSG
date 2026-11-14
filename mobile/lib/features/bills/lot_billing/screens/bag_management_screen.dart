import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../services/bill_calculation_engine.dart';

class BagManagementScreen extends StatefulWidget {
  final List<BagRowCalculation> bags;
  final ValueChanged<List<BagRowCalculation>> onBagsChanged;
  final PricingMode pricingMode;
  final ValueChanged<PricingMode> onPricingModeChanged;
  final double commonRate;
  final ValueChanged<double> onCommonRateChanged;
  final double defaultBagWeight;
  final ValueChanged<double> onDefaultBagWeightChanged;

  const BagManagementScreen({
    super.key,
    required this.bags,
    required this.onBagsChanged,
    required this.pricingMode,
    required this.onPricingModeChanged,
    required this.commonRate,
    required this.onCommonRateChanged,
    required this.defaultBagWeight,
    required this.onDefaultBagWeightChanged,
  });

  @override
  State<BagManagementScreen> createState() => _BagManagementScreenState();
}

class _BagManagementScreenState extends State<BagManagementScreen> {
  late TextEditingController _totalBagsController;
  late TextEditingController _commonRateController;
  late TextEditingController _defaultWeightController;

  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, TextEditingController> _rateControllers = {};

  @override
  void initState() {
    super.initState();
    _totalBagsController = TextEditingController(text: widget.bags.length.toString());
    _commonRateController = TextEditingController(
      text: widget.commonRate > 0 ? widget.commonRate.toStringAsFixed(2) : '',
    );
    _defaultWeightController = TextEditingController(
      text: widget.defaultBagWeight > 0 ? widget.defaultBagWeight.toStringAsFixed(0) : '50',
    );
    _syncBagControllers();
  }

  @override
  void didUpdateWidget(covariant BagManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bags.length != oldWidget.bags.length) {
      if (_totalBagsController.text != widget.bags.length.toString()) {
        _totalBagsController.text = widget.bags.length.toString();
      }
      _syncBagControllers();
    }
  }

  void _syncBagControllers() {
    // Keep controllers in sync with bags list
    for (int i = 0; i < widget.bags.length; i++) {
      final bag = widget.bags[i];
      if (!_weightControllers.containsKey(i)) {
        _weightControllers[i] = TextEditingController(text: bag.weight > 0 ? bag.weight.toStringAsFixed(1) : '');
      } else {
        final text = bag.weight > 0 ? bag.weight.toStringAsFixed(1) : '';
        if (_weightControllers[i]!.text != text && double.tryParse(_weightControllers[i]!.text) != bag.weight) {
          _weightControllers[i]!.text = text;
        }
      }

      if (!_rateControllers.containsKey(i)) {
        _rateControllers[i] = TextEditingController(text: bag.rate > 0 ? bag.rate.toStringAsFixed(2) : '');
      } else {
        final text = bag.rate > 0 ? bag.rate.toStringAsFixed(2) : '';
        if (_rateControllers[i]!.text != text && double.tryParse(_rateControllers[i]!.text) != bag.rate) {
          _rateControllers[i]!.text = text;
        }
      }
    }
  }

  @override
  void dispose() {
    _totalBagsController.dispose();
    _commonRateController.dispose();
    _defaultWeightController.dispose();
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    for (final c in _rateControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTotalBagsChanged(String val) {
    final count = int.tryParse(val) ?? 0;
    if (count < 0) return;

    final updated = BillCalculationEngine.generateBagRows(
      count: count,
      defaultWeight: widget.defaultBagWeight,
      defaultRate: widget.commonRate,
      existingBags: widget.bags,
    );

    widget.onBagsChanged(updated);
    _syncBagControllers();
  }

  void _onCommonRateChanged(String val) {
    final rate = double.tryParse(val) ?? 0.0;
    widget.onCommonRateChanged(rate);

    if (widget.pricingMode == PricingMode.common) {
      final updated = widget.bags.map((bag) {
        return bag.copyWith(rate: rate);
      }).toList();
      widget.onBagsChanged(updated);
      _syncBagControllers();
    }
  }

  void _updateSingleBagWeight(int index, String val) {
    final weight = double.tryParse(val) ?? 0.0;
    final updated = List<BagRowCalculation>.from(widget.bags);
    updated[index] = updated[index].copyWith(weight: weight);
    widget.onBagsChanged(updated);
  }

  void _updateSingleBagRate(int index, String val) {
    final rate = double.tryParse(val) ?? 0.0;
    final updated = List<BagRowCalculation>.from(widget.bags);
    updated[index] = updated[index].copyWith(rate: rate);
    widget.onBagsChanged(updated);
  }

  void _addNewBag() {
    final updated = List<BagRowCalculation>.from(widget.bags);
    final serial = updated.length + 1;
    final rate = widget.pricingMode == PricingMode.common ? widget.commonRate : 0.0;
    updated.add(BagRowCalculation(
      serialNumber: serial,
      weight: widget.defaultBagWeight,
      rate: rate,
      amount: BillCalculationEngine.calculateBagAmount(widget.defaultBagWeight, rate),
    ));
    _totalBagsController.text = updated.length.toString();
    widget.onBagsChanged(updated);
    _syncBagControllers();
  }

  void _removeBag(int index) {
    final updated = List<BagRowCalculation>.from(widget.bags);
    updated.removeAt(index);
    // Re-index serial numbers
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(serialNumber: i + 1);
    }
    _totalBagsController.text = updated.length.toString();
    _weightControllers.remove(index)?.dispose();
    _rateControllers.remove(index)?.dispose();
    widget.onBagsChanged(updated);
    _syncBagControllers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    // Computed totals
    double totalWeight = 0.0;
    double totalGoodsAmount = 0.0;
    for (final b in widget.bags) {
      totalWeight += b.weight;
      totalGoodsAmount += b.amount;
    }
    final avgWeight = widget.bags.isNotEmpty ? (totalWeight / widget.bags.length) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity & Pricing Setup Card
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
                  'Quantity & Pricing Controls',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                // Total Bags & Default Weight Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Number of Bags *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _totalBagsController,
                            keyboardType: TextInputType.number,
                            onChanged: _onTotalBagsChanged,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                            decoration: InputDecoration(
                              hintText: 'e.g. 5',
                              suffixText: 'Bags',
                              suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: theme.textSecondary),
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Default Wt/Bag (KG)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _defaultWeightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) {
                              final w = double.tryParse(val) ?? 50.0;
                              widget.onDefaultBagWeightChanged(w);
                            },
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                            decoration: InputDecoration(
                              hintText: '50',
                              suffixText: 'KG',
                              suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: theme.textSecondary),
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Pricing Mode Toggle
                Text('Pricing Mode *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildPricingModePill(
                        title: 'Common Rate (Flat)',
                        subtitle: 'One rate applies to all bags',
                        isSelected: widget.pricingMode == PricingMode.common,
                        onTap: () {
                          widget.onPricingModeChanged(PricingMode.common);
                          if (widget.commonRate > 0) {
                            final updated = widget.bags.map((b) => b.copyWith(rate: widget.commonRate)).toList();
                            widget.onBagsChanged(updated);
                            _syncBagControllers();
                          }
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPricingModePill(
                        title: 'Individual Pricing',
                        subtitle: 'Independent rate per bag',
                        isSelected: widget.pricingMode == PricingMode.individual,
                        onTap: () => widget.onPricingModeChanged(PricingMode.individual),
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                if (widget.pricingMode == PricingMode.common) ...[
                  const SizedBox(height: 14),
                  Text('Common Rate per KG (₹) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commonRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onCommonRateChanged,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.primary),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.primary),
                      hintText: 'e.g. 250.00',
                      suffixText: '/ KG',
                      suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: theme.textSecondary),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Dynamic Bag Table Header & Metric Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Bags Weight', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                    Text(
                      '${totalWeight.toStringAsFixed(1)} KG',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.text),
                    ),
                    Text(
                      'Avg: ${avgWeight.toStringAsFixed(1)} KG / Bag',
                      style: TextStyle(fontSize: 10, color: theme.textMuted),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Goods Amount', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                    Text(
                      AppFormatters.currency(totalGoodsAmount),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.primary),
                    ),
                    Text(
                      '${widget.bags.length} Bags Loaded',
                      style: TextStyle(fontSize: 10, color: theme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Table Section Title and Add Bag Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Individual Bag Details (${widget.bags.length} Bags)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewBag,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Bag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Dynamic Bag Table Cards
          if (widget.bags.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.scale_outlined, size: 36, color: theme.textMuted),
                    const SizedBox(height: 8),
                    Text('No bags in consignment', style: TextStyle(fontWeight: FontWeight.w700, color: theme.text)),
                    const SizedBox(height: 4),
                    Text('Enter quantity above or tap "+ Add Bag"', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                  ],
                ),
              ),
            )
          else ...[
            // Table Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Text('S.No', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text('Weight (KG)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text('Rate (₹/KG)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text('Amount (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary), textAlign: TextAlign.right),
                  ),
                  const SizedBox(width: 32), // Action spacer
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Bag Rows
            ...List.generate(widget.bags.length, (index) {
              final bag = widget.bags[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    // S.No Badge
                    SizedBox(
                      width: 38,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '#${bag.serialNumber}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: theme.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Weight Input
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _weightControllers[index],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) => _updateSingleBagWeight(index, val),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          filled: true,
                          fillColor: theme.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Rate Input
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _rateControllers[index],
                        readOnly: widget.pricingMode == PricingMode.common,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) => _updateSingleBagRate(index, val),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.pricingMode == PricingMode.common ? theme.textSecondary : theme.text,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          filled: true,
                          fillColor: widget.pricingMode == PricingMode.common ? theme.accent.withValues(alpha: 0.4) : theme.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Calculated Individual Amount
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppFormatters.currency(bag.amount),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                    ),

                    // Delete Row Button
                    SizedBox(
                      width: 32,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 16, color: theme.error),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Remove Bag',
                        onPressed: () => _removeBag(index),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingModePill({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.1) : theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 14,
                  color: isSelected ? theme.primary : theme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? theme.primary : theme.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
