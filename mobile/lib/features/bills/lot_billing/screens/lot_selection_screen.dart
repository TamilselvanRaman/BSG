import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_date_selector_banner.dart';
import '../../../../data/models/lot_model.dart';
import '../../../../data/models/partner_models.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../../catalogue/widgets/product_image_view.dart';

class LotSelectionScreen extends ConsumerStatefulWidget {
  final Lot? selectedLot;
  final ValueChanged<Lot> onLotSelected;
  final DateTime billDate;
  final ValueChanged<DateTime> onBillDateChanged;
  final TextEditingController customerNameController;
  final TextEditingController customerPhoneController;
  final String? selectedCustomerId;
  final ValueChanged<String?> onCustomerSelected;

  const LotSelectionScreen({
    super.key,
    required this.selectedLot,
    required this.onLotSelected,
    required this.billDate,
    required this.onBillDateChanged,
    required this.customerNameController,
    required this.customerPhoneController,
    required this.selectedCustomerId,
    required this.onCustomerSelected,
  });

  @override
  ConsumerState<LotSelectionScreen> createState() => _LotSelectionScreenState();
}

class _LotSelectionScreenState extends ConsumerState<LotSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showNewCustomerDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final created = await showDialog<Customer>(
      context: context,
      builder: (ctx) {
        final theme = context.appTheme;
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add New Customer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Customer / Buyer Name *',
                    hint: 'e.g. Ramesh Traders',
                    controller: nameCtrl,
                    validator: (v) => AppValidators.required(v, 'Customer name is required'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Phone Number *',
                    hint: '10-digit mobile number',
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'City / Market Location (Optional)',
                    hint: 'e.g. Madurai Market',
                    controller: cityCtrl,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!dialogFormKey.currentState!.validate()) return;
                final newCust = await ref.read(appRepositoryProvider).addCustomer(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null,
                );
                if (ctx.mounted) Navigator.pop(ctx, newCust);
              },
              child: const Text('Save Customer'),
            ),
          ],
        );
      },
    );

    if (created != null && mounted) {
      widget.onCustomerSelected(created.id);
      widget.customerNameController.text = created.name;
      widget.customerPhoneController.text = created.phone;
      AppDialog.showSnackBar(context, 'Customer "${created.name}" created and selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allLots = ref.watch(lotsProvider);
    final allProducts = ref.watch(appRepositoryProvider).products;
    final customers = ref.watch(customersProvider);

    // Available lots only
    final availableLots = allLots.where((lot) {
      if (!lot.isAvailable) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesLotNo = lot.lotNumber.toLowerCase().contains(q);
        final matchesProduct = lot.productName.toLowerCase().contains(q);
        final matchesSupplier = lot.supplierName.toLowerCase().contains(q);
        final matchesEntry = (lot.entryNumber ?? '').toLowerCase().contains(q);
        return matchesLotNo || matchesProduct || matchesSupplier || matchesEntry;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selection Banner
          AppDateSelectorBanner(
            label: 'Bill Date',
            selectedDate: widget.billDate,
            onDateChanged: widget.onBillDateChanged,
          ),

          // Bill Date & Customer Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill & Buyer Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: widget.billDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          widget.onBillDateChanged(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: theme.primary),
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.date(widget.billDate),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Buyer / Customer Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Registered Buyer / Customer [Optional]',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                    ),
                    InkWell(
                      onTap: _showNewCustomerDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, size: 12, color: theme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'New Customer',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: widget.selectedCustomerId,
                  dropdownColor: theme.surface,
                  icon: Icon(Icons.arrow_drop_down, color: theme.text),
                  decoration: InputDecoration(
                    hintText: 'Select Registered Customer (or type counter buyer below)',
                    hintStyle: TextStyle(fontSize: 12, color: theme.textMuted),
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Counter Cash Buyer (Unregistered)', style: TextStyle(fontSize: 12, color: theme.text)),
                    ),
                    ...customers.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text('${c.name} (${c.phone})', style: TextStyle(fontSize: 12, color: theme.text)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    widget.onCustomerSelected(val);
                    if (val != null) {
                      final cust = customers.firstWhere((c) => c.id == val);
                      widget.customerNameController.text = cust.name;
                      widget.customerPhoneController.text = cust.phone;
                    }
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buyer / Counter Name *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.customerNameController,
                            style: TextStyle(fontSize: 13, color: theme.text),
                            decoration: InputDecoration(
                              hintText: 'e.g. Ramesh Traders',
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buyer Phone', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.customerPhoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(fontSize: 13, color: theme.text),
                            decoration: InputDecoration(
                              hintText: '98421xxxxx',
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Selected Lot Banner (if selected)
          if (widget.selectedLot != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: theme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Active Selected Lot: ${widget.selectedLot!.lotNumber}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'IN STOCK',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: theme.primary.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 10),
                  _buildLotInfoRow('Produce / Crop', widget.selectedLot!.productName, theme),
                  _buildLotInfoRow('Farmer / Seller', widget.selectedLot!.supplierName, theme),
                  _buildLotInfoRow('Arrival Date', AppFormatters.date(widget.selectedLot!.date), theme),
                  if (widget.selectedLot!.entryNumber != null)
                    _buildLotInfoRow('Entry / Lot Ref #', widget.selectedLot!.entryNumber!, theme),
                  if (widget.selectedLot!.vehicleNumber != null)
                    _buildLotInfoRow('Vehicle / Lorry #', widget.selectedLot!.vehicleNumber!, theme),
                  _buildLotInfoRow(
                    'Available Stock',
                    '${widget.selectedLot!.remainingQuantity.toStringAsFixed(1)} ${widget.selectedLot!.unit} (${widget.selectedLot!.goodsCount} Bags)',
                    theme,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Search Lots
          Text(
            'Select Lot from Inward Stock *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: theme.surface,
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
                      hintText: 'Search lot number, crop, farmer, or lorry...',
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

          const SizedBox(height: 12),

          // Available Lots List
          if (availableLots.isEmpty)
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
                    Icon(Icons.inventory_2_outlined, size: 40, color: theme.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'No available lots found in stock',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All lots have been sold out or none matched your search query.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...availableLots.map((lot) {
              final isSelected = widget.selectedLot?.id == lot.id;
              final matchedProduct = allProducts.firstWhere(
                (p) => p.name.toLowerCase() == lot.productName.toLowerCase(),
                orElse: () => allProducts.first,
              );

              return GestureDetector(
                onTap: () => widget.onLotSelected(lot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? theme.primary : theme.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      // Crop Thumbnail
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: isSelected ? theme.primary : theme.border),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: ProductImageView(
                              assetPath: lot.items.isNotEmpty ? lot.items.first.assetPath : matchedProduct.assetPath,
                              imageUrl: lot.items.isNotEmpty ? lot.items.first.imageUrl : matchedProduct.imageUrl,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Details
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
                                    color: isSelected ? theme.primary : theme.text,
                                  ),
                                ),
                                Text(
                                  AppFormatters.date(lot.date),
                                  style: TextStyle(fontSize: 10, color: theme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lot.productName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                            ),
                            Text(
                              'Farmer: ${lot.supplierName}',
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available: ${lot.remainingQuantity.toStringAsFixed(1)} ${lot.unit} • ${lot.goodsCount} Bags',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection Checkmark
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primary,
                          ),
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        )
                      else
                        Icon(Icons.chevron_right, size: 20, color: theme.textMuted),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLotInfoRow(String label, String value, AppThemeColors theme, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? theme.primary : theme.text,
            ),
          ),
        ],
      ),
    );
  }
}
