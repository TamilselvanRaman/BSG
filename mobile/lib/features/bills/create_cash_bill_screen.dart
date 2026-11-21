import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_date_selector_banner.dart';
import '../../data/models/lot_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_crop_selector_sheet.dart';
import '../catalogue/widgets/product_image_view.dart';
import 'widgets/bag_weights_table_modal.dart';

class CashBillItemDraft {
  String? lotId;
  final TextEditingController quantityController;
  final TextEditingController weightController;
  final TextEditingController sellRateController;
  List<double> individualBagWeights;

  CashBillItemDraft({
    this.lotId,
    String initialQty = '',
    String initialWeight = '',
    String initialRate = '',
    List<double>? bagWeights,
  })  : quantityController = TextEditingController(text: initialQty),
        weightController = TextEditingController(text: initialWeight),
        sellRateController = TextEditingController(text: initialRate),
        individualBagWeights = bagWeights ?? [];

  void dispose() {
    quantityController.dispose();
    weightController.dispose();
    sellRateController.dispose();
  }

  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0.0;
  double get weight => double.tryParse(weightController.text.trim()) ?? 0.0;
  double get sellRate => double.tryParse(sellRateController.text.trim()) ?? 0.0;
  double get grossAmount => (weight > 0 ? weight : quantity) * sellRate;
}

class CustomChargeDraft {
  final TextEditingController nameController;
  final TextEditingController amountController;

  CustomChargeDraft({String name = '', double amount = 0.0})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount > 0 ? amount.toStringAsFixed(0) : '');

  double get amount => double.tryParse(amountController.text.trim()) ?? 0.0;
  String get name => nameController.text.trim();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class CreateCashBillScreen extends ConsumerStatefulWidget {
  final String? initialLotId;

  const CreateCashBillScreen({super.key, this.initialLotId});

  @override
  ConsumerState<CreateCashBillScreen> createState() => _CreateCashBillScreenState();
}

class _CreateCashBillScreenState extends ConsumerState<CreateCashBillScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _billDate = DateTime.now();

  final List<CashBillItemDraft> _items = [];
  final List<CustomChargeDraft> _customCharges = [];
  final _labourChargeController = TextEditingController(text: '0');
  final _otherChargesController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _amountReceivedController = TextEditingController();

  bool _autoFillReceived = true;
  bool _isLoading = false;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items.add(CashBillItemDraft(lotId: widget.initialLotId));
  }

  @override
  void dispose() {
    for (final it in _items) {
      it.dispose();
    }
    for (final c in _customCharges) {
      c.dispose();
    }
    _labourChargeController.dispose();
    _otherChargesController.dispose();
    _discountController.dispose();
    _amountReceivedController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _grossAmount {
    return _items.fold<double>(0.0, (sum, it) => sum + it.grossAmount);
  }

  double get _totalBags => _items.fold<double>(0.0, (sum, it) => sum + it.quantity);
  double get _totalWeight =>
      _items.fold<double>(0.0, (sum, it) => sum + (it.weight > 0 ? it.weight : it.quantity));

  double get _totalAmount {
    final labour = double.tryParse(_labourChargeController.text) ?? 0;
    final other = double.tryParse(_otherChargesController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final customTotal = _customCharges.fold<double>(0.0, (sum, c) => sum + c.amount);
    return (_grossAmount + labour + other + customTotal - discount).clamp(0.0, double.infinity);
  }

  void _recalcReceived() {
    if (_autoFillReceived) {
      _amountReceivedController.text = _totalAmount.toStringAsFixed(2);
    }
  }

  void _addNewProduct() {
    setState(() {
      _items.add(CashBillItemDraft());
      _recalcReceived();
    });
  }

  void _removeProduct(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
      _recalcReceived();
    });
  }

  Future<void> _openBagWeightTable(int index, Lot? selectedLot) async {
    final item = _items[index];
    final bagCount = int.tryParse(item.quantityController.text.trim()) ?? 5;
    final totalW = double.tryParse(item.weightController.text.trim()) ?? 0.0;
    final res = await BagWeightsTableModal.show(
      context,
      initialBagCount: bagCount > 0 ? bagCount : 5,
      initialTotalWeight: totalW,
      unit: selectedLot?.unit ?? 'Kg',
      existingWeights: item.individualBagWeights.isNotEmpty ? item.individualBagWeights : null,
    );

    if (res != null) {
      setState(() {
        item.quantityController.text = res.bagCount.toString();
        item.weightController.text = res.totalWeight % 1 == 0
            ? res.totalWeight.toInt().toString()
            : res.totalWeight.toStringAsFixed(1);
        item.individualBagWeights = res.weights;
        _recalcReceived();
      });
    }
  }

  Future<void> _openCropSelector(List<Lot> availableLots, int index) async {
    final selected = await ProductCropSelectorSheet.show(
      context,
      allowMultiple: false,
    );
    if (selected != null && selected.isNotEmpty) {
      final p = selected.first;
      final matchingLot = availableLots.where((l) =>
          l.productName.toLowerCase().contains(p.name.toLowerCase()) ||
          p.name.toLowerCase().contains(l.productName.toLowerCase())).firstOrNull;
      if (!mounted) return;
      if (matchingLot != null) {
        setState(() {
          if (index < _items.length) {
            _items[index].lotId = matchingLot.id;
          }
          _recalcReceived();
        });
        AppDialog.showSnackBar(context, 'Selected lot: ${matchingLot.lotNumber} (${matchingLot.productName})');
      } else {
        AppDialog.showSnackBar(
          context,
          'Selected: ${p.name}. (Choose an inward arrival lot for stock allocation)',
        );
      }
    }
  }

  Future<void> _submitCashBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      AppDialog.showSnackBar(context, 'Please add at least one product item', isError: true);
      return;
    }

    final repo = ref.read(appRepositoryProvider);
    for (int i = 0; i < _items.length; i++) {
      final it = _items[i];
      if (it.lotId == null) {
        AppDialog.showSnackBar(context, 'Please select a lot for Product #${i + 1}', isError: true);
        return;
      }
      final l = repo.getLot(it.lotId!);
      if (l == null) {
        AppDialog.showSnackBar(context, 'Lot not found for Product #${i + 1}', isError: true);
        return;
      }
      if (it.quantity > l.remainingQuantity) {
        AppDialog.showSnackBar(
          context,
          'Product #${i + 1} (${l.productName}): Cannot bill ${it.quantity} ${l.unit}. Only ${l.remainingQuantity} ${l.unit} available in this lot.',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final received = double.tryParse(_amountReceivedController.text.trim()) ?? _totalAmount;

      final List<BillItem> billItems = _items.map((it) {
        final l = repo.getLot(it.lotId!)!;
        final q = it.quantity;
        final w = it.weight > 0 ? it.weight : q;
        final r = it.sellRate;
        return BillItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}_${it.lotId}',
          lotId: l.id,
          lotNumber: l.lotNumber,
          productName: l.productName,
          quantity: q,
          weight: w,
          unit: l.unit,
          sellRate: r,
          grossAmount: it.grossAmount,
          bagItems: it.individualBagWeights.isNotEmpty
              ? [
                  for (int j = 0; j < it.individualBagWeights.length; j++)
                    BillBagItem(
                      serialNumber: j + 1,
                      weight: it.individualBagWeights[j],
                      rate: r,
                      amount: it.individualBagWeights[j] * r,
                    ),
                ]
              : [],
        );
      }).toList();

      final firstLot = repo.getLot(billItems.first.lotId)!;
      final customExtraCharges = _customCharges
          .where((c) => c.name.isNotEmpty && c.amount > 0)
          .map((c) => BillExtraCharge(
                id: 'chg_${DateTime.now().millisecondsSinceEpoch}_${c.name.hashCode}',
                name: c.name,
                amount: c.amount,
              ))
          .toList();

      final bill = await repo.createCashBill(
        lotId: firstLot.id,
        customerId: null,
        customerName: 'Cash Customer',
        customerPhone: null,
        date: _billDate,
        quantity: _totalBags,
        weight: _totalWeight,
        sellRate: billItems.first.sellRate,
        labourCharge: double.tryParse(_labourChargeController.text.trim()) ?? 0.0,
        otherCharges: double.tryParse(_otherChargesController.text.trim()) ?? 0.0,
        discount: double.tryParse(_discountController.text.trim()) ?? 0.0,
        amountReceived: received,
        paymentMethod: _paymentMethod,
        paymentReference: _referenceController.text.trim().isNotEmpty ? _referenceController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        bagWeights: _items.first.individualBagWeights.isNotEmpty ? _items.first.individualBagWeights : null,
        items: billItems,
        extraCharges: customExtraCharges,
      );

      if (mounted) {
        _showSuccessSheet(bill.billNumber, bill.id);
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Error creating cash bill: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet(String billNumber, String billId) {
    final theme = context.appTheme;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Cash Bill Created', style: AppTypography.cardTitle.copyWith(color: theme.text)),
            const SizedBox(height: 6),
            Text('Receipt Number: $billNumber', style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'View Receipt',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pushReplacement('/bills/$billId');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/bills');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableLots = ref.watch(availableLotsProvider);
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Create Cash Bill', style: AppTypography.pageTitle.copyWith(color: theme.text)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selection Banner
              AppDateSelectorBanner(
                label: 'Bill Date',
                selectedDate: _billDate,
                onDateChanged: (d) => setState(() => _billDate = d),
              ),

              const SizedBox(height: 16),

              // Section 1: Products & Lots to Sell (Supports Multi-Product)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1. Products & Lots to Sell (${_items.length})',
                    style: AppTypography.sectionHeading.copyWith(color: theme.text),
                  ),
                  InkWell(
                    onTap: _addNewProduct,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '+ Add Product',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dynamic Item Cards
              for (int idx = 0; idx < _items.length; idx++)
                _buildProductItemCard(idx, availableLots, theme),

              // Add Product Large Action Button
              InkWell(
                onTap: _addNewProduct,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: theme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '+ Add More Products to this Bill',
                        style: TextStyle(
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Extra Charges & Discount
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. Additional Mandi Charges', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Labour / Hamali (₹)',
                            controller: _labourChargeController,
                            prefixText: '₹ ',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() => _recalcReceived()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Discount (₹)',
                            controller: _discountController,
                            prefixText: '₹ ',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() => _recalcReceived()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Other Charges (Transport / Weighing) (₹)',
                      controller: _otherChargesController,
                      prefixText: '₹ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() => _recalcReceived()),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: theme.border, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Custom Additional Charges',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.text,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _customCharges.add(CustomChargeDraft());
                              _recalcReceived();
                            });
                          },
                          icon: Icon(Icons.add_circle_outline_rounded, size: 16, color: theme.primary),
                          label: Text(
                            'Add Custom Charge',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    if (_customCharges.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'No custom extra charges added. Tap "+ Add Custom Charge" to add extra expenses (e.g. Weighbridge, Bag Stitching, Gate Pass).',
                          style: TextStyle(fontSize: 11.5, color: theme.textMuted),
                        ),
                      ),
                    ] else ...[
                      ..._customCharges.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final charge = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: charge.nameController,
                                  label: 'Charge Name',
                                  hint: 'e.g. Bag Stitching / Gate Fee',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: charge.amountController,
                                  label: 'Amount (₹)',
                                  prefixText: '₹ ',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() => _recalcReceived()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    setState(() {
                                      charge.dispose();
                                      _customCharges.removeAt(idx);
                                      _recalcReceived();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: Settlement & Amount Received
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('3. Payment Settlement', style: AppTypography.sectionHeading),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _paymentMethod == PaymentMethod.cash
                                ? 'Hand Cash'
                                : _paymentMethod == PaymentMethod.upi
                                    ? 'GPay / UPI'
                                    : _paymentMethod == PaymentMethod.bank
                                        ? 'Bank Transfer'
                                        : 'Cheque',
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

                    // Multi-Item Bill Summary Banner
                    if (_items.length > 1) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_items.length} Products Added',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.text),
                            ),
                            Text(
                              'Total: ${_totalBags.toInt()} Bags • ${_totalWeight.toStringAsFixed(1)} Kg',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Total Bill Amount Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Bill Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormatters.currency(_totalAmount),
                                style: AppTypography.amount.copyWith(
                                  color: theme.text,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          if (_amountReceivedController.text != _totalAmount.toStringAsFixed(2))
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _autoFillReceived = true;
                                  _amountReceivedController.text = _totalAmount.toStringAsFixed(2);
                                });
                              },
                              icon: const Icon(Icons.sync_rounded, size: 15),
                              label: const Text('Full Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount Collected Field
                    AppTextField(
                      label: 'Cash Amount Collected (₹) *',
                      controller: _amountReceivedController,
                      prefixText: '₹ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: AppValidators.nonNegativeNumber,
                      onChanged: (_) {
                        setState(() => _autoFillReceived = false);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Payment Method Options: Hand Cash, GPay, Bank, Cheque
                    Text(
                      'Payment Collection Method *',
                      style: AppTypography.label.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Select Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPaymentMethodChip(
                          method: PaymentMethod.cash,
                          label: 'Hand Cash',
                          icon: Icons.payments_outlined,
                          theme: theme,
                        ),
                        _buildPaymentMethodChip(
                          method: PaymentMethod.upi,
                          label: 'GPay / UPI / PhonePe',
                          icon: Icons.qr_code_2_rounded,
                          theme: theme,
                        ),
                        _buildPaymentMethodChip(
                          method: PaymentMethod.bank,
                          label: 'Bank Transfer',
                          icon: Icons.account_balance_outlined,
                          theme: theme,
                        ),
                        _buildPaymentMethodChip(
                          method: PaymentMethod.cheque,
                          label: 'Cheque',
                          icon: Icons.description_outlined,
                          theme: theme,
                        ),
                      ],
                    ),

                    // Conditional Reference / UTR Number
                    if (_paymentMethod != PaymentMethod.cash) ...[
                      const SizedBox(height: 14),
                      AppTextField(
                        label: _paymentMethod == PaymentMethod.upi
                            ? 'UPI / GPay / Transaction Ref'
                            : _paymentMethod == PaymentMethod.bank
                                ? 'Bank Ref / UTR Number'
                                : 'Cheque Number',
                        hint: _paymentMethod == PaymentMethod.upi
                            ? 'e.g. UPI Ref / Txn ID'
                            : _paymentMethod == PaymentMethod.bank
                                ? 'e.g. UTR / IMPS Ref'
                                : 'e.g. Cheque 6-digit number',
                        controller: _referenceController,
                        prefixIcon: Icon(
                          _paymentMethod == PaymentMethod.upi
                              ? Icons.qr_code_rounded
                              : _paymentMethod == PaymentMethod.bank
                                  ? Icons.account_balance_rounded
                                  : Icons.tag_rounded,
                          size: 18,
                          color: theme.primary,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Notes / Remarks Option
                    AppTextField(
                      label: 'Remarks / Notes (Optional)',
                      hint: 'e.g. Cash collected at counter, discount details...',
                      controller: _notesController,
                      maxLines: 2,
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 20, color: theme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              AppButton(
                text: 'Save Cash Bill & Generate Receipt',
                isLoading: _isLoading,
                onPressed: _submitCashBill,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItemCard(int idx, List<Lot> availableLots, AppThemeColors theme) {
    final item = _items[idx];
    final activeLotId = item.lotId ?? (availableLots.isNotEmpty ? availableLots.first.id : null);
    if (item.lotId == null && activeLotId != null) {
      item.lotId = activeLotId;
    }
    final selectedLot = activeLotId != null ? ref.read(appRepositoryProvider).getLot(activeLotId) : null;
    final matchingProduct = selectedLot != null
        ? (ref.read(appRepositoryProvider).getProductByName(selectedLot.productName) ??
            ref.read(productsProvider).where((p) {
              final n = selectedLot.productName.toLowerCase();
              final pn = p.name.toLowerCase();
              return n.contains(pn) || pn.contains(n);
            }).firstOrNull)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Product #${idx + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (selectedLot != null)
                  Expanded(
                    child: Text(
                      selectedLot.productName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_items.length > 1)
                  IconButton(
                    onPressed: () => _removeProduct(idx),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    tooltip: 'Remove Product',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Select Lot Dropdown
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: activeLotId,
                    dropdownColor: theme.surface,
                    icon: Icon(Icons.arrow_drop_down, color: theme.text),
                    decoration: InputDecoration(
                      hintText: 'Select lot from inventory',
                      hintStyle: TextStyle(color: theme.textMuted),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: availableLots.map((Lot l) {
                      return DropdownMenuItem<String>(
                        value: l.id,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${l.lotNumber} • ${l.productName}',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${AppFormatters.quantity(l.remainingQuantity, l.unit)} left',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return availableLots.map((l) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${l.lotNumber} • ${l.productName}',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${AppFormatters.quantity(l.remainingQuantity, l.unit)} left',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    onChanged: (val) {
                      setState(() {
                        item.lotId = val;
                        _recalcReceived();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openCropSelector(availableLots, idx),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 14, color: theme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Crop',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (selectedLot != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.isDark ? theme.surface : Colors.white,
                        border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: ProductImageView(
                            assetPath: selectedLot.items.isNotEmpty
                                ? selectedLot.items.first.assetPath
                                : matchingProduct?.assetPath,
                            imageUrl: selectedLot.items.isNotEmpty
                                ? selectedLot.items.first.imageUrl
                                : matchingProduct?.imageUrl,
                            size: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supplier: ${selectedLot.supplierName}',
                            style: TextStyle(fontSize: 11, color: theme.textSecondary),
                          ),
                          Text(
                            'Available Stock: ${AppFormatters.quantity(selectedLot.remainingQuantity, selectedLot.unit)} (Cost: ${AppFormatters.currency(selectedLot.costRate)}/${selectedLot.unit})',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Bag Quantity, Weight, Scale Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 5,
                  child: AppTextField(
                    label: 'Bag Quantity *',
                    hint: 'e.g. 50 Bags',
                    controller: item.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: AppValidators.positiveNumber,
                    onChanged: (v) {
                      if (item.weightController.text.isEmpty) {
                        item.weightController.text = v;
                      }
                      setState(() => _recalcReceived());
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: AppTextField(
                    label: 'Weight (${selectedLot?.unit ?? 'Kg'})',
                    hint: 'e.g. 2500',
                    controller: item.weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() => _recalcReceived()),
                  ),
                ),
                const SizedBox(width: 6),
                // Scale button to open individual bag weights table
                InkWell(
                  onTap: () => _openBagWeightTable(idx, selectedLot),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: item.individualBagWeights.isNotEmpty ? theme.primary : theme.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scale_rounded,
                          size: 18,
                          color: item.individualBagWeights.isNotEmpty ? Colors.white : theme.primary,
                        ),
                        Text(
                          item.individualBagWeights.isNotEmpty
                              ? '${item.individualBagWeights.length} Bags'
                              : 'Weights',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: item.individualBagWeights.isNotEmpty ? Colors.white : theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Selling Rate & Item Subtotal
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 6,
                  child: AppTextField(
                    label: 'Selling Rate (₹ per ${selectedLot?.unit ?? 'unit'}) *',
                    hint: 'e.g. 35',
                    controller: item.sellRateController,
                    prefixText: '₹ ',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: AppValidators.positiveNumber,
                    onChanged: (_) => setState(() => _recalcReceived()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Subtotal', style: TextStyle(fontSize: 10.5, color: theme.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.currency(item.grossAmount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip({
    required PaymentMethod method,
    required String label,
    required IconData icon,
    required AppThemeColors theme,
  }) {
    final isSelected = _paymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.12) : theme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.primary : theme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.primary : theme.text,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Icon(Icons.check_circle_rounded, size: 14, color: theme.primary),
            ],
          ],
        ),
      ),
    );
  }
}
