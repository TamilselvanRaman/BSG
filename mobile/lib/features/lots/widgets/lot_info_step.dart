import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_date_selector_banner.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../catalogue/widgets/product_image_view.dart';
import '../../catalogue/widgets/product_crop_selector_sheet.dart';

class LotInfoStep extends ConsumerStatefulWidget {
  final Product? selectedProduct;
  final VoidCallback onChangeProduct;
  final List<Product> additionalProducts;
  final ValueChanged<Product>? onAddProduct;
  final ValueChanged<int>? onRemoveAdditionalProduct;
  final String? selectedSupplierId;
  final ValueChanged<String?> onSupplierChanged;
  final TextEditingController entryNumberController;
  final TextEditingController vehicleNumberController;
  final DateTime lotDate;
  final ValueChanged<DateTime> onDateChanged;
  final String lotNumberPreview;
  final bool isEmbedded;

  const LotInfoStep({
    super.key,
    required this.selectedProduct,
    required this.onChangeProduct,
    this.additionalProducts = const [],
    this.onAddProduct,
    this.onRemoveAdditionalProduct,
    required this.selectedSupplierId,
    required this.onSupplierChanged,
    required this.entryNumberController,
    required this.vehicleNumberController,
    required this.lotDate,
    required this.onDateChanged,
    required this.lotNumberPreview,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<LotInfoStep> createState() => _LotInfoStepState();
}

class _LotInfoStepState extends ConsumerState<LotInfoStep> {
  final TextEditingController _seqController = TextEditingController();
  String _currentPrefix = '';

  @override
  void initState() {
    super.initState();
    _syncFromParent();
  }

  @override
  void didUpdateWidget(covariant LotInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSupplierId != widget.selectedSupplierId ||
        oldWidget.entryNumberController.text != widget.entryNumberController.text) {
      _syncFromParent();
    }
  }

  @override
  void dispose() {
    _seqController.dispose();
    super.dispose();
  }

  void _syncFromParent() {
    if (widget.selectedSupplierId != null) {
      final repo = ref.read(appRepositoryProvider);
      final supplier = repo.getSupplier(widget.selectedSupplierId!);
      final prefix = repo.getOrGenerateSupplierPrefix(
        widget.selectedSupplierId!,
        supplierName: supplier?.name,
      );
      _currentPrefix = prefix;

      final fullText = widget.entryNumberController.text.trim();
      if (fullText.isEmpty) {
        final next = repo.getNextEntryNumberForSupplier(
          widget.selectedSupplierId!,
          supplierName: supplier?.name,
        );
        widget.entryNumberController.text = next;
        final parts = next.split('-');
        _seqController.text = parts.length > 1 ? parts[1] : next;
      } else {
        if (fullText.startsWith('$prefix-')) {
          _seqController.text = fullText.substring(prefix.length + 1);
        } else {
          final parts = fullText.split('-');
          _seqController.text = parts.length > 1 ? parts[1] : fullText;
        }
      }
    } else {
      _currentPrefix = '';
      _seqController.clear();
    }
  }

  void _onSeqChanged(String val) {
    final clean = val.trim();
    if (_currentPrefix.isNotEmpty) {
      widget.entryNumberController.text = '$_currentPrefix-$clean';
    } else {
      widget.entryNumberController.text = clean;
    }
  }

  void _refreshAutoSequence() {
    if (widget.selectedSupplierId != null) {
      final repo = ref.read(appRepositoryProvider);
      final supplier = repo.getSupplier(widget.selectedSupplierId!);
      final next = repo.getNextEntryNumberForSupplier(
        widget.selectedSupplierId!,
        supplierName: supplier?.name,
      );
      widget.entryNumberController.text = next;
      final parts = next.split('-');
      setState(() {
        _seqController.text = parts.length > 1 ? parts[1] : next;
      });
    }
  }

  void _showNewSupplierDialog(BuildContext context) {
    final theme = context.appTheme;
    final messenger = ScaffoldMessenger.of(context);
    final dialogFormKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_add_rounded, color: theme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add New Supplier / Party',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
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
                  label: 'Supplier Name *',
                  hint: 'e.g. Tamil or Tamilselvan',
                  controller: nameCtrl,
                  validator: (v) => AppValidators.required(v, 'Supplier name is required'),
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
                  label: 'City / Village (Optional)',
                  hint: 'e.g. Salem, Pollachi',
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
              if (dialogFormKey.currentState?.validate() ?? false) {
                final repo = ref.read(appRepositoryProvider);
                final newSupplier = await repo.addSupplier(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null,
                );
                // Assign fixed prefix immediately
                final prefix = repo.getOrGenerateSupplierPrefix(newSupplier.id, supplierName: newSupplier.name);
                final nextEntry = repo.getNextEntryNumberForSupplier(newSupplier.id, supplierName: newSupplier.name);

                if (ctx.mounted) Navigator.pop(ctx);

                widget.onSupplierChanged(newSupplier.id);
                widget.entryNumberController.text = nextEntry;

                if (mounted) {
                  setState(() {
                    _currentPrefix = prefix;
                    final parts = nextEntry.split('-');
                    _seqController.text = parts.length > 1 ? parts[1] : nextEntry;
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Supplier "${newSupplier.name}" added with fixed prefix "$prefix"'),
                      backgroundColor: theme.primary,
                    ),
                  );
                }
              }
            },
            child: const Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final suppliers = ref.watch(suppliersProvider);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inward Arrival Date Selector Banner
          AppDateSelectorBanner(
            label: 'Inward Arrival Date',
            selectedDate: widget.lotDate,
            onDateChanged: widget.onDateChanged,
          ),

          // 1. Compact Product Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: ProductImageView(
                      assetPath: widget.selectedProduct?.assetPath,
                      imageUrl: widget.selectedProduct?.imageUrl,
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedProduct?.name ?? 'No product selected',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.selectedProduct?.categoryName ?? 'Crop',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Unit: ${widget.selectedProduct?.defaultUnit ?? 'Kg'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: widget.onChangeProduct,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primary,
                    side: BorderSide(color: theme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Additional Products stored in this Lot
          if (widget.additionalProducts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...widget.additionalProducts.asMap().entries.map((entry) {
              final idx = entry.key;
              final p = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: theme.primary.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: ClipOval(
                        child: ProductImageView(
                          assetPath: p.assetPath,
                          imageUrl: p.imageUrl,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: theme.text,
                            ),
                          ),
                          Text(
                            '${p.categoryName} • Unit: ${p.defaultUnit}',
                            style: TextStyle(fontSize: 11, color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                      tooltip: 'Remove Product',
                      onPressed: () => widget.onRemoveAdditionalProduct?.call(idx),
                    ),
                  ],
                ),
              );
            }),
          ],

          // "+ Add Another Product to this Inward Lot" Button
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            child: InkWell(
              onTap: () async {
                final selected = await ProductCropSelectorSheet.show(context, allowMultiple: false);
                if (selected != null && selected.isNotEmpty) {
                  widget.onAddProduct?.call(selected.first);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 17, color: theme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Add More Products to this Inward Lot',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Inward Entry Form Card
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
                      'Supplier & Consignment Info',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.lotNumberPreview,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Supplier Dropdown Header with + New Supplier button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Supplier (Farmer / Source) *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showNewSupplierDialog(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, size: 13, color: theme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'New Supplier',
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
                  initialValue: widget.selectedSupplierId,
                  dropdownColor: theme.surface,
                  icon: Icon(Icons.arrow_drop_down, color: theme.text),
                  decoration: InputDecoration(
                    hintText: 'Select or Search Supplier',
                    hintStyle: TextStyle(color: theme.textMuted),
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: suppliers.map((s) {
                    final prefixTag = s.entryPrefix != null && s.entryPrefix!.isNotEmpty
                        ? '[${s.entryPrefix}] '
                        : '';
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '$prefixTag${s.name} (${s.phone})',
                        style: TextStyle(fontSize: 13, color: theme.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return suppliers.map((s) {
                      final prefixTag = s.entryPrefix != null && s.entryPrefix!.isNotEmpty
                          ? '[${s.entryPrefix}] '
                          : '';
                      return Text(
                        '$prefixTag${s.name} (${s.phone})',
                        style: TextStyle(fontSize: 13, color: theme.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }).toList();
                  },
                  onChanged: (val) {
                    widget.onSupplierChanged(val);
                    if (val != null) {
                      final repo = ref.read(appRepositoryProvider);
                      final nextEntry = repo.getNextEntryNumberForSupplier(val);
                      widget.entryNumberController.text = nextEntry;
                      final prefix = repo.getOrGenerateSupplierPrefix(val);
                      setState(() {
                        _currentPrefix = prefix;
                        final parts = nextEntry.split('-');
                        _seqController.text = parts.length > 1 ? parts[1] : nextEntry;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                // Date & Entry Number Row - Height & Baseline Aligned
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 18,
                            child: Text(
                              'Inward Date *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: widget.lotDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                widget.onDateChanged(picked);
                              }
                            },
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppFormatters.date(widget.lotDate),
                                    style: TextStyle(fontSize: 13, color: theme.text, fontWeight: FontWeight.w600),
                                  ),
                                  Icon(Icons.calendar_today_outlined, size: 16, color: theme.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Entry creation date',
                            style: TextStyle(fontSize: 9.5, color: theme.textMuted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Entry Number Field with Fixed Prefix & Auto-Sequence
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Entry Number *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                if (_currentPrefix.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: theme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Prefix: $_currentPrefix',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.selectedSupplierId != null ? theme.primary.withValues(alpha: 0.6) : theme.border,
                                width: widget.selectedSupplierId != null ? 1.2 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Fixed Prefix Pill (LOCKED)
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: widget.selectedSupplierId != null
                                        ? theme.primary.withValues(alpha: 0.12)
                                        : theme.border.withValues(alpha: 0.2),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                                    border: Border(right: BorderSide(color: theme.border)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.selectedSupplierId != null ? Icons.lock_outline_rounded : Icons.tag_rounded,
                                          size: 13,
                                          color: widget.selectedSupplierId != null ? theme.primary : theme.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _currentPrefix.isNotEmpty ? _currentPrefix : '--',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: widget.selectedSupplierId != null ? theme.primary : theme.textMuted,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Numeric Sequence Field
                                Expanded(
                                  child: TextField(
                                    controller: _seqController,
                                    keyboardType: TextInputType.number,
                                    enabled: widget.selectedSupplierId != null,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.text,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: widget.selectedSupplierId != null ? '001' : 'Select party',
                                      hintStyle: TextStyle(fontSize: 12, color: theme.textMuted),
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onChanged: _onSeqChanged,
                                  ),
                                ),

                                // Auto Refresh Sequence button
                                if (widget.selectedSupplierId != null)
                                  IconButton(
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    tooltip: 'Calculate next sequential number',
                                    color: theme.primary,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    onPressed: _refreshAutoSequence,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.selectedSupplierId != null
                                ? 'Fixed prefix "$_currentPrefix" • Seq auto-increments'
                                : 'Select supplier to auto-assign prefix & number',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: theme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Vehicle Number
                Text(
                  'Vehicle / Lorry Number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: widget.vehicleNumberController,
                  style: TextStyle(fontSize: 13, color: theme.text),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.local_shipping_outlined, size: 18, color: theme.textMuted),
                    hintText: 'e.g. TN 38 AZ 4492',
                    hintStyle: TextStyle(color: theme.textMuted),
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
        ],
      );

    if (widget.isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}
