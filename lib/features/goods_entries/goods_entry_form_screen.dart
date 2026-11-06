import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';
import '../../data/models/goods_entry.dart';
import '../../data/models/goods_entry_item.dart';
import '../../data/models/commodity.dart';
import 'widgets/commodity_selector.dart';
import 'widgets/buyer_selector_card.dart';
import 'widgets/enterprise_accordion_section.dart';
import 'widgets/live_summary_banner.dart';
import 'widgets/quick_save_bottom_bar.dart';
import 'widgets/produce_lines_table.dart';

typedef _ProductLineController = ProduceTableItem;

class GoodsEntryFormScreen extends ConsumerStatefulWidget {
  const GoodsEntryFormScreen({super.key});

  @override
  ConsumerState<GoodsEntryFormScreen> createState() => _GoodsEntryFormScreenState();
}

class _GoodsEntryFormScreenState extends ConsumerState<GoodsEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Accordion Section expansion tracking
  final Set<int> _expandedSections = {1, 2, 3, 4};

  // Section 1: Buyer & Commodity
  String? _selectedCustomerId;
  late TextEditingController _goodsNameCtrl;
  late FocusNode _goodsNameFocusNode;

  // Section 2: Lot & Logistics
  late TextEditingController _entryNoCtrl;
  DateTime _entryDate = DateTime.now();
  late TextEditingController _lotNoCtrl;
  late TextEditingController _goodsCountCtrl;
  late TextEditingController _vehicleNoCtrl;
  late FocusNode _vehicleNoFocusNode;
  late TextEditingController _notesCtrl;

  // Section 3: Product line items
  final List<_ProductLineController> _productLines = [];

  // Section 4: Initial Payment controllers
  late TextEditingController _initialPaymentAmountCtrl;
  String _initialPaymentMode = 'Cash';
  late TextEditingController _initialPaymentRefCtrl;
  late TextEditingController _initialPaymentNotesCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final nextNumber = 'GE-2026-${(ref.read(goodsEntriesProvider).length + 1).toString().padLeft(3, '0')}';
    _entryNoCtrl = TextEditingController(text: nextNumber);
    _lotNoCtrl = TextEditingController(text: 'LOT-TN-${(ref.read(goodsEntriesProvider).length + 1).toString().padLeft(2, '0')}');
    _goodsCountCtrl = TextEditingController(text: '40');
    _goodsNameCtrl = TextEditingController(text: 'Country Tomatoes');
    _vehicleNoCtrl = TextEditingController(text: 'TN 30 BD 1045');
    _notesCtrl = TextEditingController();

    _goodsNameFocusNode = FocusNode();
    _vehicleNoFocusNode = FocusNode();

    _initialPaymentAmountCtrl = TextEditingController(text: '5000');
    _initialPaymentRefCtrl = TextEditingController();
    _initialPaymentNotesCtrl = TextEditingController();

    // Default buyer if available
    final buyers = ref.read(customersProvider).where((c) => c.customerType != CustomerType.seller).toList();
    if (buyers.isNotEmpty) {
      _selectedCustomerId = buyers.first.id;
    }

    // Add initial product line
    _productLines.add(_ProductLineController(
      name: 'Country Tomato A-Grade',
      weight: '800',
      qty: '40',
      costRate: '24',
      sellRate: '30',
      labourCharge: '400',
    ));
  }

  @override
  void dispose() {
    _entryNoCtrl.dispose();
    _lotNoCtrl.dispose();
    _goodsCountCtrl.dispose();
    _goodsNameCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _notesCtrl.dispose();
    _goodsNameFocusNode.dispose();
    _vehicleNoFocusNode.dispose();
    for (final line in _productLines) {
      line.dispose();
    }
    _initialPaymentAmountCtrl.dispose();
    _initialPaymentRefCtrl.dispose();
    _initialPaymentNotesCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSection(int section) {
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
  }

  void _openSection(int section) {
    setState(() {
      _expandedSections.add(section);
    });
  }

  void _addProductLine() {
    setState(() {
      _productLines.add(_ProductLineController(
        name: '${_goodsNameCtrl.text} B-Grade',
        weight: '400',
        qty: '20',
        costRate: '20',
        sellRate: '25',
        labourCharge: '200',
      ));
    });
  }

  void _onCommoditySelected(Commodity commodity) {
    setState(() {
      _goodsNameCtrl.text = commodity.name;
      if (_productLines.isNotEmpty) {
        final firstLine = _productLines.first;
        if (firstLine.nameCtrl.text.isEmpty || firstLine.nameCtrl.text.toLowerCase().contains('tomato')) {
          firstLine.nameCtrl.text = '${commodity.name} A-Grade';
          firstLine.costRateCtrl.text = commodity.defaultCostRate.toStringAsFixed(0);
          firstLine.sellRateCtrl.text = commodity.defaultSellRate.toStringAsFixed(0);
        }
      }
      _expandedSections.add(2);
    });
    _vehicleNoFocusNode.requestFocus();
  }

  void _removeProductLine(int index) {
    if (_productLines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one product line is required.')),
      );
      return;
    }
    setState(() {
      _productLines[index].dispose();
      _productLines.removeAt(index);
    });
  }


  double get _totalEntryAmount {
    return _productLines.fold(0.0, (sum, line) => sum + line.lineTotal);
  }

  double get _totalWeight {
    return _productLines.fold(0.0, (sum, line) => sum + (double.tryParse(line.weightCtrl.text) ?? 0.0));
  }

  int get _totalBags {
    return int.tryParse(_goodsCountCtrl.text) ?? 0;
  }

  double get _initialPaymentValue {
    return double.tryParse(_initialPaymentAmountCtrl.text) ?? 0.0;
  }

  double get _netDue {
    final net = _totalEntryAmount - _initialPaymentValue;
    return net > 0 ? net : 0.0;
  }

  void _adjustBags(int delta) {
    final current = int.tryParse(_goodsCountCtrl.text) ?? 0;
    final updated = (current + delta).clamp(1, 10000);
    setState(() {
      _goodsCountCtrl.text = updated.toString();
    });
  }

  void _saveEntry({required bool isDraft}) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify required fields marked with *'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Buyer for this goods entry'),
          backgroundColor: AppColors.danger,
        ),
      );
      _openSection(1);
      return;
    }

    final initialPaymentAmount = _initialPaymentValue;
    if (initialPaymentAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Initial payment amount cannot be negative'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final List<GoodsEntryItem> items = [];
    for (int i = 0; i < _productLines.length; i++) {
      final line = _productLines[i];
      items.add(GoodsEntryItem(
        id: 'gei-${const Uuid().v4().substring(0, 8)}',
        productName: line.nameCtrl.text.isNotEmpty ? line.nameCtrl.text : 'Product ${i + 1}',
        goodsName: _goodsNameCtrl.text,
        quantity: double.tryParse(line.qtyCtrl.text) ?? 0.0,
        weight: double.tryParse(line.weightCtrl.text) ?? 0.0,
        costRate: double.tryParse(line.costRateCtrl.text) ?? 0.0,
        sellRate: double.tryParse(line.sellRateCtrl.text) ?? 0.0,
        labourCharge: line.labourCharge,
      ));
    }

    final entryId = 'ge-${const Uuid().v4().substring(0, 8)}';
    final entry = GoodsEntry(
      id: entryId,
      entryNumber: _entryNoCtrl.text.trim(),
      customerId: _selectedCustomerId!,
      entryDate: _entryDate,
      lotNumber: _lotNoCtrl.text.trim(),
      goodsCount: _totalBags,
      goodsName: _goodsNameCtrl.text.trim(),
      productName: items.isNotEmpty ? items.first.productName : '',
      vehicleNumber: _vehicleNoCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: items,
      initialPaymentAmount: initialPaymentAmount,
      initialPaymentMode: _initialPaymentMode,
      initialPaymentRef: _initialPaymentRefCtrl.text.trim(),
      initialPaymentNotes: _initialPaymentNotesCtrl.text.trim(),
      status: isDraft ? GoodsEntryStatus.draft : GoodsEntryStatus.confirmed,
      createdAt: DateTime.now(),
    );

    ref.read(appStateProvider.notifier).addGoodsEntry(entry);

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goods Entry ${_entryNoCtrl.text} saved successfully!'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider).where((c) => c.customerType != CustomerType.seller).toList();
    final selectedCustomer = customers.where((c) => c.id == _selectedCustomerId).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Enterprise crisp slate background
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goods Arrival Entry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text('Mandi Unloading & Weighbridge Settlement', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (_expandedSections.length == 4) {
                  _expandedSections.clear();
                } else {
                  _expandedSections.addAll([1, 2, 3, 4]);
                }
              });
            },
            icon: Icon(
              _expandedSections.length == 4 ? Icons.unfold_less : Icons.unfold_more,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            label: Text(
              _expandedSections.length == 4 ? 'Collapse All' : 'Expand All',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: QuickSaveBottomBar(
        totalAmount: _totalEntryAmount,
        netDue: _netDue,
        isSaving: _isSaving,
        onSaveConfirmed: () => _saveEntry(isDraft: false),
        onSaveDraft: () => _saveEntry(isDraft: true),
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Corporate Summary Banner
                LiveSummaryBanner(
                  totalBags: _totalBags,
                  totalWeight: _totalWeight,
                  totalAmount: _totalEntryAmount,
                  initialPayment: _initialPaymentValue,
                  netDue: _netDue,
                ),

                // Section 1: Buyer & Commodity Selection
                EnterpriseAccordionSection(
                  stepNumber: 1,
                  title: 'Party & Commodity Selection',
                  subtitle: 'Select registered mandi buyer and produce catalog',
                  summaryBadge: selectedCustomer != null
                      ? '${selectedCustomer.name.split(' ').first} • ${_goodsNameCtrl.text}'
                      : null,
                  isExpanded: _expandedSections.contains(1),
                  isCompleted: _selectedCustomerId != null && _goodsNameCtrl.text.isNotEmpty,
                  onToggle: () => _toggleSection(1),
                  onContinue: () {
                    _openSection(2);
                    _vehicleNoFocusNode.requestFocus();
                  },
                  continueLabel: 'Continue to Lot & Logistics',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Select Mandi Buyer *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      BuyerSelectorCard(
                        selectedCustomer: selectedCustomer,
                        customers: customers,
                        onSelected: (c) => setState(() => _selectedCustomerId = c.id),
                        onAddNewCustomer: () => context.push('/customers/new'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CommoditySelector(
                        controller: _goodsNameCtrl,
                        focusNode: _goodsNameFocusNode,
                        onNext: () {
                          _openSection(2);
                          _vehicleNoFocusNode.requestFocus();
                        },
                        onCommodityChanged: _onCommoditySelected,
                      ),
                    ],
                  ),
                ),

                // Section 2: Lot Details & Logistics
                EnterpriseAccordionSection(
                  stepNumber: 2,
                  title: 'Lot Details & Logistics',
                  subtitle: 'Lot number, bags count, vehicle, and arrival date',
                  summaryBadge: 'Lot: ${_lotNoCtrl.text} • ${_goodsCountCtrl.text} Bags • ${_vehicleNoCtrl.text}',
                  isExpanded: _expandedSections.contains(2),
                  isCompleted: _lotNoCtrl.text.isNotEmpty && _goodsCountCtrl.text.isNotEmpty,
                  onToggle: () => _toggleSection(2),
                  onContinue: () => _openSection(3),
                  continueLabel: 'Continue to Product Lines & Rates',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Entry Number & Date
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Entry Number (Auto)',
                              controller: _entryNoCtrl,
                              readOnly: true,
                              prefixIcon: Icons.tag,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildDatePickerField('Arrival Date *', _entryDate, (d) => setState(() => _entryDate = d)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Lot Number & Bags Count
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Lot Number *',
                              hint: 'e.g. LOT-TN-01',
                              controller: _lotNoCtrl,
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              prefixIcon: Icons.qr_code,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  label: 'Total Goods Count (Bags/Units) *',
                                  hint: '40',
                                  controller: _goodsCountCtrl,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  prefixIcon: Icons.all_inbox_outlined,
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 6),
                                // Quick Bags Stepper Chips
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildBagsChip('+10', () => _adjustBags(10)),
                                      const SizedBox(width: 4),
                                      _buildBagsChip('+25', () => _adjustBags(25)),
                                      const SizedBox(width: 4),
                                      _buildBagsChip('+50', () => _adjustBags(50)),
                                      const SizedBox(width: 4),
                                      _buildBagsChip('+100', () => _adjustBags(100)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Vehicle Number & Notes
                      CustomTextField(
                        label: 'Vehicle Number (Optional)',
                        hint: 'e.g. TN 30 BD 1045',
                        controller: _vehicleNoCtrl,
                        focusNode: _vehicleNoFocusNode,
                        prefixIcon: Icons.local_shipping_outlined,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: 'Unloading Notes & Remarks (Optional)',
                        hint: 'e.g. Direct mandi arrival from Krishnagiri farm',
                        controller: _notesCtrl,
                        prefixIcon: Icons.notes_outlined,
                      ),
                    ],
                  ),
                ),

                // Section 3: Product Lines, Weights & Rates (Spreadsheet Table View)
                EnterpriseAccordionSection(
                  stepNumber: 3,
                  title: 'Product Lines, Weights & Rates',
                  subtitle: 'Itemize varieties, weights, rates, and hamali in real-time spreadsheet table',
                  summaryBadge: '${_productLines.length} Lines • ${_totalWeight.toStringAsFixed(0)} kg • ${CurrencyFormatter.format(_totalEntryAmount)}',
                  isExpanded: _expandedSections.contains(3),
                  isCompleted: _productLines.isNotEmpty && _totalWeight > 0,
                  onToggle: () => _toggleSection(3),
                  onContinue: () => _openSection(4),
                  continueLabel: 'Continue to Advance Payment Settlement',
                  content: ProduceLinesTable(
                    items: _productLines,
                    defaultProduceName: _goodsNameCtrl.text,
                    onAddLine: _addProductLine,
                    onRemoveLine: _removeProductLine,
                    onChanged: () => setState(() {}),
                  ),
                ),

                // Section 4: Initial Advance Settlement
                EnterpriseAccordionSection(
                  stepNumber: 4,
                  title: 'Initial Advance Settlement',
                  subtitle: 'Unloading advance received from buyer at vehicle arrival',
                  summaryBadge: 'Advance: ${CurrencyFormatter.format(_initialPaymentValue)} ($_initialPaymentMode)',
                  isExpanded: _expandedSections.contains(4),
                  isCompleted: true,
                  onToggle: () => _toggleSection(4),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenSurface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unloading Advance Token',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryGreenDark),
                                      ),
                                      Text(
                                        'Recorded in buyer ledger and deducted automatically from final bill',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Advance Amount input
                            CustomTextField(
                              label: 'Advance Received Amount (₹) *',
                              hint: '5000',
                              controller: _initialPaymentAmountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.currency_rupee,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 8),

                            // Quick Advance Chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildAdvanceChip('₹0 (Nil)', '0'),
                                _buildAdvanceChip('₹2,000', '2000'),
                                _buildAdvanceChip('₹5,000', '5000'),
                                _buildAdvanceChip('₹10,000', '10000'),
                                _buildAdvanceChip('₹20,000', '20000'),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Payment Mode
                            const Text('Payment Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Row(
                              children: ['Cash', 'UPI', 'Bank Transfer', 'Cheque'].map((mode) {
                                final isSelected = _initialPaymentMode == mode;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3),
                                    child: InkWell(
                                      onTap: () => setState(() => _initialPaymentMode = mode),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primaryGreen : AppColors.cardSurface,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryGreen : AppColors.border,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            mode,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              color: isSelected ? Colors.white : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Reference
                            CustomTextField(
                              label: 'Transaction Reference / UTR Number',
                              hint: 'e.g. UPI/405102/104928',
                              controller: _initialPaymentRefCtrl,
                              prefixIcon: Icons.receipt_long_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Extra space for sticky bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBagsChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGreenDark),
        ),
      ),
    );
  }

  Widget _buildAdvanceChip(String label, String amount) {
    final isSelected = _initialPaymentAmountCtrl.text == amount;
    return InkWell(
      onTap: () {
        setState(() {
          _initialPaymentAmountCtrl.text = amount;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }


  Widget _buildDatePickerField(String label, DateTime date, Function(DateTime) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2025),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: AppColors.cardSurface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormatter.format(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
