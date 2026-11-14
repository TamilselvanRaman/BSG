import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';

enum CustomExpenseType {
  fixed,
  perBag,
  perKg,
}

class CustomLotExpense {
  final String id;
  final String name;
  final double rate;
  final CustomExpenseType type;

  const CustomLotExpense({
    required this.id,
    required this.name,
    required this.rate,
    required this.type,
  });

  double calculateAmount(int bagCount, double netWeight) {
    switch (type) {
      case CustomExpenseType.fixed:
        return rate;
      case CustomExpenseType.perBag:
        return rate * bagCount;
      case CustomExpenseType.perKg:
        return rate * netWeight;
    }
  }

  String get typeLabel {
    switch (type) {
      case CustomExpenseType.fixed:
        return 'Fixed Amount';
      case CustomExpenseType.perBag:
        return '₹${rate.toStringAsFixed(2)} / Bag';
      case CustomExpenseType.perKg:
        return '₹${rate.toStringAsFixed(2)} / Kg';
    }
  }
}

class ExpensesChargesStep extends StatelessWidget {
  final TextEditingController labourController;
  final TextEditingController transportController;
  final TextEditingController sangamController;
  final TextEditingController mamoolController;
  final TextEditingController otherChargesController;
  final List<CustomLotExpense> customExpenses;
  final ValueChanged<CustomLotExpense> onAddCustomExpense;
  final ValueChanged<int> onRemoveCustomExpense;
  final int totalPackages;
  final double netWeight;
  final VoidCallback onChanged;
  final bool isEmbedded;

  const ExpensesChargesStep({
    super.key,
    required this.labourController,
    required this.transportController,
    required this.sangamController,
    required this.mamoolController,
    required this.otherChargesController,
    required this.customExpenses,
    required this.onAddCustomExpense,
    required this.onRemoveCustomExpense,
    required this.totalPackages,
    required this.netWeight,
    required this.onChanged,
    this.isEmbedded = false,
  });

  double get labour => double.tryParse(labourController.text) ?? 0.0;
  double get transport => double.tryParse(transportController.text) ?? 0.0;
  double get sangam => double.tryParse(sangamController.text) ?? 0.0;
  double get mamool => double.tryParse(mamoolController.text) ?? 0.0;
  double get other => double.tryParse(otherChargesController.text) ?? 0.0;

  double get customTotal => customExpenses.fold(0.0, (acc, item) => acc + item.calculateAmount(totalPackages, netWeight));

  double get totalExpenses => labour + transport + sangam + mamool + other + customTotal;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Total Expenses Highlight Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Inward & Mandi Charges',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(totalExpenses),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${5 + customExpenses.length} Expense Items',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Standard Inward Charges
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
                  'Standard Inward Mandi Charges',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                _buildExpenseField(
                  title: 'Labour / Hamali (Unloading Charges)',
                  controller: labourController,
                  hint: '0.00',
                  icon: Icons.front_hand_outlined,
                  theme: theme,
                ),
                const SizedBox(height: 12),

                _buildExpenseField(
                  title: 'Transport / Freight (Lorry Rent)',
                  controller: transportController,
                  hint: '0.00',
                  icon: Icons.local_shipping_outlined,
                  theme: theme,
                ),
                const SizedBox(height: 12),

                _buildExpenseField(
                  title: 'Sangam / Mandi Commission / Cess',
                  controller: sangamController,
                  hint: '0.00',
                  icon: Icons.account_balance_outlined,
                  theme: theme,
                ),
                const SizedBox(height: 12),

                _buildExpenseField(
                  title: 'Mamool / Weighing / Miscellaneous Fee',
                  controller: mamoolController,
                  hint: '0.00',
                  icon: Icons.receipt_long_outlined,
                  theme: theme,
                ),
                const SizedBox(height: 12),

                _buildExpenseField(
                  title: 'Other Inward Charges',
                  controller: otherChargesController,
                  hint: '0.00',
                  icon: Icons.more_horiz_outlined,
                  theme: theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Custom / Dynamic Charges Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Additional Charges',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddCustomExpenseModal(context, theme),
                icon: Icon(Icons.add_circle_outline, size: 16, color: theme.primary),
                label: Text(
                  'Add Custom Charge',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (customExpenses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border, style: BorderStyle.solid),
              ),
              child: Center(
                child: Text(
                  'No custom charges added. Tap above to add Ice charges, bag stitching, or godown charges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: theme.textMuted),
                ),
              ),
            )
          else
            ...List.generate(customExpenses.length, (index) {
              final exp = customExpenses[index];
              final amount = exp.calculateAmount(totalPackages, netWeight);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        Text(
                          exp.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exp.typeLabel,
                          style: TextStyle(fontSize: 11, color: theme.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          AppFormatters.currency(amount),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: theme.error),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onRemoveCustomExpense(index),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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

  Widget _buildExpenseField({
    required String title,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppThemeColors theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
            hintText: hint,
            hintStyle: TextStyle(color: theme.textMuted),
            filled: true,
            fillColor: theme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _showAddCustomExpenseModal(BuildContext context, AppThemeColors theme) {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    CustomExpenseType chosenType = CustomExpenseType.fixed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Custom Charge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: theme.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      labelText: 'Charge Name *',
                      labelStyle: TextStyle(color: theme.textSecondary),
                      hintText: 'e.g. Ice Packets, Stitching, Stacking',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<CustomExpenseType>(
                    initialValue: chosenType,
                    dropdownColor: theme.surface,
                    decoration: InputDecoration(
                      labelText: 'Calculation Mode',
                      labelStyle: TextStyle(color: theme.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: CustomExpenseType.fixed,
                        child: Text('Fixed Total Amount (₹)'),
                      ),
                      DropdownMenuItem(
                        value: CustomExpenseType.perBag,
                        child: Text('Rate Per Bag (₹ / bag)'),
                      ),
                      DropdownMenuItem(
                        value: CustomExpenseType.perKg,
                        child: Text('Rate Per Kg (₹ / kg)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => chosenType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      labelText: 'Rate / Amount (₹) *',
                      labelStyle: TextStyle(color: theme.textSecondary),
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                        if (name.isEmpty || rate <= 0) return;

                        final item = CustomLotExpense(
                          id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          rate: rate,
                          type: chosenType,
                        );

                        onAddCustomExpense(item);
                        onChanged();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Charge', style: TextStyle(fontWeight: FontWeight.w700)),
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
}

