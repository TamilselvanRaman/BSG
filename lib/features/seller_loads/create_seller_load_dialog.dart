import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/app_state.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/seller_load.dart';
import '../billing/widgets/bag_weights_entry_dialog.dart';

class CreateSellerLoadDialog extends ConsumerStatefulWidget {
  final SellerLoad? initialLoad;

  const CreateSellerLoadDialog({super.key, this.initialLoad});

  static Future<SellerLoad?> show(BuildContext context, {SellerLoad? initialLoad}) {
    return showDialog<SellerLoad>(
      context: context,
      builder: (ctx) => CreateSellerLoadDialog(initialLoad: initialLoad),
    );
  }

  @override
  ConsumerState<CreateSellerLoadDialog> createState() => _CreateSellerLoadDialogState();
}

class _CreateSellerLoadDialogState extends ConsumerState<CreateSellerLoadDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _loadNoCtrl;
  late TextEditingController _vehicleCtrl;
  late TextEditingController _commodityCtrl;
  late TextEditingController _bagsCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _advanceCtrl;
  late TextEditingController _commissionCtrl;
  late TextEditingController _notesCtrl;

  Customer? _selectedSeller;

  @override
  void initState() {
    super.initState();
    final init = widget.initialLoad;
    final existingLoads = ref.read(sellerLoadsProvider);
    final nextNo = 'LOAD-2026-${(existingLoads.length + 1).toString().padLeft(3, '0')}';

    _loadNoCtrl = TextEditingController(text: init?.loadNumber ?? nextNo);
    _vehicleCtrl = TextEditingController(text: init?.vehicleNumber ?? 'TN 30 BD 1045');
    _commodityCtrl = TextEditingController(text: init?.commodity ?? 'Country Tomatoes');
    _bagsCtrl = TextEditingController(text: init?.totalBags.toString() ?? '50');
    _weightCtrl = TextEditingController(text: init != null ? init.grossWeight.toStringAsFixed(0) : '1250');
    _advanceCtrl = TextEditingController(text: init != null ? init.advancePaidToSeller.toStringAsFixed(0) : '5000');
    _commissionCtrl = TextEditingController(text: init?.commissionPercent.toString() ?? '5.0');
    _notesCtrl = TextEditingController(text: init?.notes ?? '');

    // Default to seller
    final sellers = ref.read(customersProvider).where((c) => c.customerType == CustomerType.seller || c.customerType == CustomerType.both).toList();
    if (init != null) {
      _selectedSeller = sellers.where((s) => s.id == init.sellerId).firstOrNull ??
          Customer(
            id: init.sellerId,
            name: init.sellerName,
            village: init.village,
            phone: init.phone,
            customerType: CustomerType.seller,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    } else if (sellers.isNotEmpty) {
      _selectedSeller = sellers.first;
    }
  }

  @override
  void dispose() {
    _loadNoCtrl.dispose();
    _vehicleCtrl.dispose();
    _commodityCtrl.dispose();
    _bagsCtrl.dispose();
    _weightCtrl.dispose();
    _advanceCtrl.dispose();
    _commissionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSeller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farmer / seller'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (widget.initialLoad != null) {
      final updated = widget.initialLoad!.copyWith(
        loadNumber: _loadNoCtrl.text.trim(),
        sellerId: _selectedSeller!.id,
        sellerName: _selectedSeller!.name,
        village: _selectedSeller!.village,
        phone: _selectedSeller!.phone,
        vehicleNumber: _vehicleCtrl.text.trim(),
        commodity: _commodityCtrl.text.trim(),
        totalBags: int.tryParse(_bagsCtrl.text.trim()) ?? 0,
        grossWeight: double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
        advancePaidToSeller: double.tryParse(_advanceCtrl.text.trim()) ?? 0.0,
        commissionPercent: double.tryParse(_commissionCtrl.text.trim()) ?? 5.0,
        notes: _notesCtrl.text.trim(),
      );
      ref.read(appStateProvider.notifier).updateSellerLoad(updated);
      Navigator.of(context).pop(updated);
      return;
    }

    final newLoad = SellerLoad(
      id: const Uuid().v4(),
      loadNumber: _loadNoCtrl.text.trim(),
      sellerId: _selectedSeller!.id,
      sellerName: _selectedSeller!.name,
      village: _selectedSeller!.village,
      phone: _selectedSeller!.phone,
      vehicleNumber: _vehicleCtrl.text.trim(),
      commodity: _commodityCtrl.text.trim(),
      totalBags: int.tryParse(_bagsCtrl.text.trim()) ?? 0,
      grossWeight: double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
      advancePaidToSeller: double.tryParse(_advanceCtrl.text.trim()) ?? 0.0,
      commissionPercent: double.tryParse(_commissionCtrl.text.trim()) ?? 5.0,
      notes: _notesCtrl.text.trim(),
      status: SellerLoadStatus.arrived,
      arrivalDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    ref.read(appStateProvider.notifier).addSellerLoad(newLoad);
    Navigator.of(context).pop(newLoad);
  }

  @override
  Widget build(BuildContext context) {
    final sellers = ref.watch(customersProvider).where((c) => c.customerType == CustomerType.seller || c.customerType == CustomerType.both).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: AppColors.cardSurface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.initialLoad != null ? 'Edit Inward Seller Load' : 'Create Inward Seller Load', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text(widget.initialLoad != null ? 'Update truck arrival, bags & advance details' : 'Record farmer arrival, lorry load & advance payment', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Load Number & Arrival Date
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Load Number *',
                              controller: _loadNoCtrl,
                              prefixIcon: Icons.tag,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomTextField(
                              label: 'Vehicle / Lorry No *',
                              controller: _vehicleCtrl,
                              hint: 'TN 30 BD 1045',
                              prefixIcon: Icons.directions_bus_outlined,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Seller / Farmer Picker
                      const Text('Select Farmer / Seller *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Customer>(
                            isExpanded: true,
                            value: _selectedSeller,
                            hint: const Text('Choose Farmer / Supplier'),
                            items: sellers.map((s) {
                              return DropdownMenuItem<Customer>(
                                value: s,
                                child: Text('${s.name} (${s.village})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (c) => setState(() => _selectedSeller = c),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Commodity & Bags
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Commodity Produce *',
                              controller: _commodityCtrl,
                              hint: 'Country Tomatoes',
                              prefixIcon: Icons.inventory_2_outlined,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomTextField(
                              label: 'Total Bags Arrived *',
                              controller: _bagsCtrl,
                              hint: '50',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.all_inbox,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Gross Weight & Advance to Seller
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Gross Weight (kg) *',
                              controller: _weightCtrl,
                              hint: '1250',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.scale,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomTextField(
                              label: 'Advance Paid to Farmer (₹)',
                              controller: _advanceCtrl,
                              hint: '5000',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.currency_rupee,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Bag-by-Bag Scale Button
                      InkWell(
                        onTap: () async {
                          final count = int.tryParse(_bagsCtrl.text.trim()) ?? 10;
                          final res = await BagWeightsEntryDialog.show(
                            context,
                            initialBags: count,
                          );
                          if (res != null) {
                            setState(() {
                              _bagsCtrl.text = res.totalBags.toString();
                              _weightCtrl.text = res.netWeight.toStringAsFixed(1);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.scale_rounded, size: 16, color: Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                              Text(
                                'Enter Individual Bag Weights (${_bagsCtrl.text.isEmpty ? "10" : _bagsCtrl.text} Bags)',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Commission % & Notes
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Mandi Commission (%)',
                              controller: _commissionCtrl,
                              hint: '5.0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.percent,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: CustomTextField(
                              label: 'Remarks / Driver Notes',
                              controller: _notesCtrl,
                              hint: 'Morning harvest',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Create Load', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
