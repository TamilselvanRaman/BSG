import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/bill_model.dart';

class AdditionalChargesScreen extends StatefulWidget {
  final double goodsAmount;
  final TextEditingController transportFeeController;
  final TextEditingController transportDescController;
  final TextEditingController labourFeeController;
  final TextEditingController labourDescController;
  final TextEditingController mandiFeeController;
  final TextEditingController mandiDescController;
  final List<BillExtraCharge> extraCharges;
  final ValueChanged<List<BillExtraCharge>> onExtraChargesChanged;
  final VoidCallback onChanged;

  const AdditionalChargesScreen({
    super.key,
    required this.goodsAmount,
    required this.transportFeeController,
    required this.transportDescController,
    required this.labourFeeController,
    required this.labourDescController,
    required this.mandiFeeController,
    required this.mandiDescController,
    required this.extraCharges,
    required this.onExtraChargesChanged,
    required this.onChanged,
  });

  @override
  State<AdditionalChargesScreen> createState() => _AdditionalChargesScreenState();
}

class _AdditionalChargesScreenState extends State<AdditionalChargesScreen> {
  double get transportFee => double.tryParse(widget.transportFeeController.text) ?? 0.0;
  double get labourFee => double.tryParse(widget.labourFeeController.text) ?? 0.0;
  double get mandiFee => double.tryParse(widget.mandiFeeController.text) ?? 0.0;

  double get totalExtraCharges => widget.extraCharges.fold(0.0, (acc, item) => acc + item.amount);
  double get totalCharges => transportFee + labourFee + mandiFee + totalExtraCharges;
  double get grandTotal => widget.goodsAmount + totalCharges;

  void _showAddExtraChargeModal(BuildContext context, AppThemeColors theme) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
                  'Add Extra Consignment Charge',
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
            TextField(
              controller: nameController,
              autofocus: true,
              style: TextStyle(color: theme.text),
              decoration: InputDecoration(
                labelText: 'Charge Name *',
                labelStyle: TextStyle(color: theme.textSecondary),
                hintText: 'e.g. Packing Fee, Loading, Commission, Ice',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
              decoration: InputDecoration(
                labelText: 'Charge Amount (₹) *',
                labelStyle: TextStyle(color: theme.textSecondary),
                prefixText: '₹ ',
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: TextStyle(color: theme.text),
              decoration: InputDecoration(
                labelText: 'Description / Remarks [Optional]',
                labelStyle: TextStyle(color: theme.textSecondary),
                hintText: 'Optional note or reference',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (name.isEmpty || amount <= 0) return;

                  final newCharge = BillExtraCharge(
                    id: 'ec_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    amount: amount,
                    description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                  );

                  final updated = List<BillExtraCharge>.from(widget.extraCharges)..add(newCharge);
                  widget.onExtraChargesChanged(updated);
                  widget.onChanged();
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
      ),
    );
  }

  void _removeExtraCharge(int index) {
    final updated = List<BillExtraCharge>.from(widget.extraCharges)..removeAt(index);
    widget.onExtraChargesChanged(updated);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Charges Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Charges Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryLine('Goods Subtotal', AppFormatters.currency(widget.goodsAmount), theme),
                if (transportFee > 0)
                  _buildSummaryLine('Transport Fee', '+ ${AppFormatters.currency(transportFee)}', theme),
                if (labourFee > 0)
                  _buildSummaryLine('Labour Fee', '+ ${AppFormatters.currency(labourFee)}', theme),
                if (mandiFee > 0)
                  _buildSummaryLine('Mandi Fee', '+ ${AppFormatters.currency(mandiFee)}', theme),
                if (totalExtraCharges > 0)
                  _buildSummaryLine('Extra Charges (${widget.extraCharges.length})', '+ ${AppFormatters.currency(totalExtraCharges)}', theme),
                const SizedBox(height: 8),
                Divider(color: theme.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.text),
                    ),
                    Text(
                      AppFormatters.currency(grandTotal),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Default Inward Charges Form
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
                  'Default Statutory & Inward Charges',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.text),
                ),
                const SizedBox(height: 14),

                // 1. Transport Fee
                _buildChargeInput(
                  title: '1. Transport Fee (₹)',
                  amountController: widget.transportFeeController,
                  descController: widget.transportDescController,
                  hint: '0.00',
                  icon: Icons.local_shipping_outlined,
                  theme: theme,
                ),

                const SizedBox(height: 14),

                // 2. Labour Fee
                _buildChargeInput(
                  title: '2. Labour / Hamali Fee (₹)',
                  amountController: widget.labourFeeController,
                  descController: widget.labourDescController,
                  hint: '0.00',
                  icon: Icons.front_hand_outlined,
                  theme: theme,
                ),

                const SizedBox(height: 14),

                // 3. Mandi Fee
                _buildChargeInput(
                  title: '3. Mandi / Market Cess Fee (₹)',
                  amountController: widget.mandiFeeController,
                  descController: widget.mandiDescController,
                  hint: '0.00',
                  icon: Icons.account_balance_outlined,
                  theme: theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Dynamic Extra Charges Header & Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extra Custom Charges (${widget.extraCharges.length})',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.text),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddExtraChargeModal(context, theme),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Extra Charge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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

          // Extra Charges List
          if (widget.extraCharges.isEmpty)
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
                  'No extra charges added. Tap "Add Extra Charge" to include Packing, Loading, or Commission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: theme.textMuted),
                ),
              ),
            )
          else
            ...List.generate(widget.extraCharges.length, (index) {
              final charge = widget.extraCharges[index];
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
                          charge.name,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                        ),
                        if (charge.description != null && charge.description!.isNotEmpty)
                          Text(
                            charge.description!,
                            style: TextStyle(fontSize: 11, color: theme.textSecondary),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          AppFormatters.currency(charge.amount),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: theme.error),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _removeExtraCharge(index),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildChargeInput({
    required String title,
    required TextEditingController amountController,
    required TextEditingController descController,
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
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) {
                  setState(() {});
                  widget.onChanged();
                },
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                  hintText: hint,
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: TextField(
                controller: descController,
                style: TextStyle(fontSize: 12, color: theme.text),
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: TextStyle(fontSize: 11, color: theme.textMuted),
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value, AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
        ],
      ),
    );
  }
}

