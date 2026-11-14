import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/lot_model.dart';
import '../../data/models/lot_config_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/app_repository.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/product_selection_step.dart';
import 'widgets/lot_info_step.dart';
import 'widgets/bags_goods_step.dart';
import 'widgets/weight_details_step.dart';
import 'widgets/rate_pricing_step.dart';
import 'widgets/expenses_charges_step.dart';
import 'widgets/payment_details_step.dart';
import 'widgets/final_review_step.dart';

class CreateLotScreen extends ConsumerStatefulWidget {
  final String? initialSupplierId;

  const CreateLotScreen({super.key, this.initialSupplierId});

  @override
  ConsumerState<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends ConsumerState<CreateLotScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Crop & Supplier',
    'Bags & Pricing',
    'Charges & Review',
  ];

  // --- Step 0: Product State ---
  Product? _selectedProduct;
  final List<Product> _additionalProducts = [];

  // --- Step 1: Lot Info State ---
  String? _selectedSupplierId;
  final TextEditingController _entryNumberController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  DateTime _lotDate = DateTime.now();
  final String _lotNumberPreview = 'LOT-2026-AUTOGEN';

  // --- Step 2: Bags & Goods State ---
  final List<BagEntryItem> _bagEntries = [];

  // --- Step 3: Weight State ---
  WeightEntryMode _weightMode = WeightEntryMode.fullWeighbridge;
  final TextEditingController _grossWeightController = TextEditingController();
  final TextEditingController _tareWeightController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();

  // --- Step 4: Rate & Pricing State ---
  PricingRateBasis _rateBasis = PricingRateBasis.perKg;
  final TextEditingController _purchaseRateController = TextEditingController();
  final TextEditingController _sellingRateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');

  // --- Step 5: Charges State ---
  final TextEditingController _labourController = TextEditingController(text: '0');
  final TextEditingController _transportController = TextEditingController(text: '0');
  final TextEditingController _sangamController = TextEditingController(text: '0');
  final TextEditingController _mamoolController = TextEditingController(text: '0');
  final TextEditingController _otherChargesController = TextEditingController(text: '0');
  final List<CustomLotExpense> _customExpenses = [];

  // --- Step 6: Payment State ---
  PaymentMode _paymentMode = PaymentMode.cash;
  final TextEditingController _advancePaidController = TextEditingController(text: '0');
  final TextEditingController _remainingRentController = TextEditingController(text: '0');
  final TextEditingController _paidAmountController = TextEditingController(text: '0');
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.initialSupplierId;
    if (_selectedSupplierId != null) {
      final repo = ref.read(appRepositoryProvider);
      _entryNumberController.text = repo.getNextEntryNumberForSupplier(_selectedSupplierId!);
    }

    // Initialize first bag entry
    _bagEntries.add(BagEntryItem(
      id: 'bag_1',
      title: 'Standard Consignment Bags',
      count: '100',
      weightPerUnit: '50',
      unit: 'Kg',
    ));

    // Preset sample values for convenient rapid entry
    _grossWeightController.text = '14500';
    _tareWeightController.text = '9500';
    _netWeightController.text = '5000';
    _purchaseRateController.text = '32.00';
    _sellingRateController.text = '38.00';
    _labourController.text = '500';
    _transportController.text = '2500';

    // Automatically load configured custom expenses from repository
    final configs = ref.read(appRepositoryProvider).getLotExpenseConfigs(activeOnly: true);
    for (final cfg in configs) {
      if (!['exp_labour', 'exp_sangam', 'exp_rent', 'exp_mamool', 'exp_transport', 'exp_other'].contains(cfg.id)) {
        _customExpenses.add(CustomLotExpense(
          id: cfg.id,
          name: cfg.name,
          rate: cfg.defaultAmount,
          type: cfg.calcType == LotExpenseCalcType.perBag
              ? CustomExpenseType.perBag
              : (cfg.calcType == LotExpenseCalcType.perKg ? CustomExpenseType.perKg : CustomExpenseType.fixed),
        ));
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryNumberController.dispose();
    _vehicleNumberController.dispose();
    for (final b in _bagEntries) {
      b.dispose();
    }
    _grossWeightController.dispose();
    _tareWeightController.dispose();
    _netWeightController.dispose();
    _purchaseRateController.dispose();
    _sellingRateController.dispose();
    _discountController.dispose();
    _labourController.dispose();
    _transportController.dispose();
    _sangamController.dispose();
    _mamoolController.dispose();
    _otherChargesController.dispose();
    _advancePaidController.dispose();
    _remainingRentController.dispose();
    _paidAmountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Calculated values
  int get totalPackages => _bagEntries.fold<int>(0, (acc, item) => acc + item.count);
  double get netWeight => double.tryParse(_netWeightController.text) ?? 0.0;
  double get grossWeight => double.tryParse(_grossWeightController.text) ?? 0.0;
  double get tareWeight => double.tryParse(_tareWeightController.text) ?? 0.0;
  double get purchaseRate => double.tryParse(_purchaseRateController.text) ?? 0.0;
  double get sellingRate => double.tryParse(_sellingRateController.text) ?? 0.0;
  double get discountAmount => double.tryParse(_discountController.text) ?? 0.0;

  double get grossGoodsTotal {
    switch (_rateBasis) {
      case PricingRateBasis.perKg:
        return netWeight * purchaseRate;
      case PricingRateBasis.perBag:
        return totalPackages * purchaseRate;
      case PricingRateBasis.fixedLot:
        return purchaseRate;
    }
  }

  double get netGoodsAmount => (grossGoodsTotal - discountAmount).clamp(0.0, double.infinity);

  double get labourCharge => double.tryParse(_labourController.text) ?? 0.0;
  double get transportCharge => double.tryParse(_transportController.text) ?? 0.0;
  double get sangamCharge => double.tryParse(_sangamController.text) ?? 0.0;
  double get mamoolCharge => double.tryParse(_mamoolController.text) ?? 0.0;
  double get otherCharges => double.tryParse(_otherChargesController.text) ?? 0.0;

  double get customExpensesTotal => _customExpenses.fold<double>(
        0.0,
        (acc, item) => acc + item.calculateAmount(totalPackages, netWeight),
      );

  double get totalInwardExpenses =>
      labourCharge + transportCharge + sangamCharge + mamoolCharge + otherCharges + customExpensesTotal;

  double get grandTotal => netGoodsAmount + totalInwardExpenses;
  double get advancePaid => double.tryParse(_advancePaidController.text) ?? 0.0;
  double get remainingRent => double.tryParse(_remainingRentController.text) ?? 0.0;
  double get paidAmount => double.tryParse(_paidAmountController.text) ?? 0.0;

  void _goToStep(int step) {
    if (step < 0 || step >= _stepTitles.length) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_selectedProduct == null) {
          _showSnackbar('Please select a product/crop to continue');
          return false;
        }
        if (_selectedSupplierId == null) {
          _showSnackbar('Please select a supplier / farmer');
          return false;
        }
        return true;
      case 1:
        if (totalPackages <= 0) {
          _showSnackbar('Please enter at least 1 bag/package count');
          return false;
        }
        if (netWeight <= 0) {
          _showSnackbar('Please enter or calculate a valid net weight');
          return false;
        }
        if (purchaseRate <= 0) {
          _showSnackbar('Please enter a purchase cost rate');
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  void _onNext() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _stepTitles.length - 1) {
        _goToStep(_currentStep + 1);
      } else {
        _saveLot(createAnother: false);
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      context.pop();
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    final theme = context.appTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? theme.error : theme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveLot({required bool createAnother}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(appRepositoryProvider);
      final supplier = repo.getSupplier(_selectedSupplierId ?? '');

      final supplierName = supplier?.name ?? 'General Supplier';

      final newLot = await repo.createLot(
        supplierId: _selectedSupplierId ?? 'sup_general',
        supplierName: supplierName,
        date: _lotDate,
        entryNumber: _entryNumberController.text.trim().isNotEmpty ? _entryNumberController.text.trim() : null,
        vehicleNumber: _vehicleNumberController.text.trim().isNotEmpty ? _vehicleNumberController.text.trim() : null,
        productName: [
          _selectedProduct?.name ?? 'Agricultural Crop',
          ..._additionalProducts.map((p) => p.name),
        ].join(' + '),
        goodsCount: totalPackages,
        quantity: netWeight,
        weight: netWeight,
        unit: _selectedProduct?.defaultUnit ?? 'Kg',
        costRate: purchaseRate,
        labourCharge: labourCharge,
        transportCharge: transportCharge,
        otherCharges: otherCharges + sangamCharge + mamoolCharge + customExpensesTotal,
        items: [
          if (_bagEntries.isNotEmpty)
            ..._bagEntries.asMap().entries.map((e) {
              final item = e.value;
              return LotItem(
                id: 'item_${DateTime.now().millisecondsSinceEpoch}_${e.key}',
                productId: _selectedProduct?.id,
                productName: item.titleController.text.trim().isNotEmpty
                    ? item.titleController.text.trim()
                    : (_selectedProduct?.name ?? 'Crop'),
                assetPath: _selectedProduct?.assetPath,
                imageUrl: _selectedProduct?.imageUrl,
                goodsCount: item.count,
                quantity: item.estimatedTotalWeight > 0 ? item.estimatedTotalWeight : (netWeight / _bagEntries.length),
                weight: item.estimatedTotalWeight > 0 ? item.estimatedTotalWeight : (netWeight / _bagEntries.length),
                unit: item.unit,
                costRate: item.ratePerKg > 0 ? item.ratePerKg : purchaseRate,
              );
            })
          else
            LotItem(
              id: 'item_${DateTime.now().millisecondsSinceEpoch}',
              productId: _selectedProduct?.id,
              productName: _selectedProduct?.name ?? 'Crop',
              assetPath: _selectedProduct?.assetPath,
              imageUrl: _selectedProduct?.imageUrl,
              goodsCount: totalPackages,
              quantity: netWeight,
              weight: netWeight,
              unit: _selectedProduct?.defaultUnit ?? 'Kg',
              costRate: purchaseRate,
            ),
          for (int i = 0; i < _additionalProducts.length; i++)
            LotItem(
              id: 'item_add_${DateTime.now().millisecondsSinceEpoch}_$i',
              productId: _additionalProducts[i].id,
              productName: _additionalProducts[i].name,
              assetPath: _additionalProducts[i].assetPath,
              imageUrl: _additionalProducts[i].imageUrl,
              goodsCount: 1,
              quantity: 0,
              weight: 0,
              unit: _additionalProducts[i].defaultUnit,
              costRate: _additionalProducts[i].defaultRate ?? purchaseRate,
            ),
        ],
      );

      if (!mounted) return;

      _showSnackbar('Lot ${newLot.lotNumber} created successfully!', isError: false);

      if (createAnother) {
        setState(() {
          _currentStep = 0;
          _selectedProduct = null;
          _entryNumberController.clear();
          _vehicleNumberController.clear();
          _grossWeightController.clear();
          _tareWeightController.clear();
          _netWeightController.clear();
          _purchaseRateController.clear();
          _paidAmountController.clear();
          _isSubmitting = false;
        });
        _pageController.jumpToPage(0);
      } else {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackbar('Error creating lot: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final suppliers = ref.watch(suppliersProvider);
    final supplierName = suppliers.where((s) => s.id == _selectedSupplierId).firstOrNull?.name ?? 'General Supplier';

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Create New Lot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.text,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.text),
          onPressed: _onBack,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.error),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 8-Step Horizontal Interactive Indicator
          StepProgressIndicator(
            currentStep: _currentStep,
            totalSteps: _stepTitles.length,
            stepTitles: _stepTitles,
            onStepTapped: (step) {
              _goToStep(step);
            },
          ),

          // Main Step Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Controlled step progression
              children: [
                // Page 0: Crop & Supplier Information
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedProduct == null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.accent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.touch_app_rounded, size: 18, color: theme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tap a crop to select and proceed',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ProductSelectionStep(
                          isEmbedded: true,
                          selectedProduct: _selectedProduct,
                          onProductSelected: (p) {
                            setState(() {
                              _selectedProduct = p;
                              if (p.defaultRate != null && p.defaultRate! > 0) {
                                _purchaseRateController.text = p.defaultRate!.toStringAsFixed(2);
                              }
                            });
                          },
                        ),
                      ] else ...[
                        LotInfoStep(
                          isEmbedded: true,
                          selectedProduct: _selectedProduct,
                          additionalProducts: _additionalProducts,
                          onAddProduct: (p) => setState(() => _additionalProducts.add(p)),
                          onRemoveAdditionalProduct: (i) => setState(() => _additionalProducts.removeAt(i)),
                          onChangeProduct: () => setState(() => _selectedProduct = null),
                          selectedSupplierId: _selectedSupplierId,
                          onSupplierChanged: (val) {
                            setState(() {
                              _selectedSupplierId = val;
                              if (val != null) {
                                final repo = ref.read(appRepositoryProvider);
                                _entryNumberController.text = repo.getNextEntryNumberForSupplier(val);
                              }
                            });
                          },
                          entryNumberController: _entryNumberController,
                          vehicleNumberController: _vehicleNumberController,
                          lotDate: _lotDate,
                          onDateChanged: (val) => setState(() => _lotDate = val),
                          lotNumberPreview: _lotNumberPreview,
                        ),
                      ],
                    ],
                  ),
                ),

                // Page 1: Bags, Weight & Pricing
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Consignment Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.inventory_2_outlined, color: theme.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedProduct?.name ?? 'Agricultural Crop',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.text),
                                  ),
                                  Text(
                                    'Party: $supplierName • Entry: ${_entryNumberController.text}',
                                    style: TextStyle(fontSize: 11, color: theme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Section A: Bags & Goods Details
                      BagsGoodsStep(
                        isEmbedded: true,
                        bagEntries: _bagEntries,
                        onAddEntry: () {
                          setState(() {
                            _bagEntries.add(BagEntryItem(
                              id: 'bag_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Bag Lot #${_bagEntries.length + 1}',
                              count: '50',
                              weightPerUnit: '50',
                              unit: _selectedProduct?.defaultUnit ?? 'Kg',
                            ));
                          });
                        },
                        onRemoveEntry: (index) {
                          setState(() {
                            final item = _bagEntries.removeAt(index);
                            item.dispose();
                          });
                        },
                        onChanged: () => setState(() {}),
                        defaultUnit: _selectedProduct?.defaultUnit ?? 'Kg',
                      ),

                      const SizedBox(height: 20),

                      // Section B: Weight Details
                      WeightDetailsStep(
                        isEmbedded: true,
                        mode: _weightMode,
                        onModeChanged: (mode) => setState(() => _weightMode = mode),
                        grossWeightController: _grossWeightController,
                        tareWeightController: _tareWeightController,
                        netWeightController: _netWeightController,
                        totalPackages: totalPackages,
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // Section C: Rate & Pricing Details
                      RatePricingStep(
                        isEmbedded: true,
                        rateBasis: _rateBasis,
                        onRateBasisChanged: (basis) => setState(() => _rateBasis = basis),
                        purchaseRateController: _purchaseRateController,
                        sellingRateController: _sellingRateController,
                        discountController: _discountController,
                        netWeight: netWeight,
                        totalPackages: totalPackages,
                        onChanged: () => setState(() {}),
                      ),
                    ],
                  ),
                ),

                // Page 2: Charges, Payment & Final Review
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section A: Mandi & Inward Charges
                      ExpensesChargesStep(
                        isEmbedded: true,
                        labourController: _labourController,
                        transportController: _transportController,
                        sangamController: _sangamController,
                        mamoolController: _mamoolController,
                        otherChargesController: _otherChargesController,
                        customExpenses: _customExpenses,
                        onAddCustomExpense: (exp) {
                          setState(() => _customExpenses.add(exp));
                          ref.read(appRepositoryProvider).addLotExpenseConfig(
                            name: exp.name,
                            calcType: exp.type == CustomExpenseType.perBag
                                ? LotExpenseCalcType.perBag
                                : (exp.type == CustomExpenseType.perKg
                                    ? LotExpenseCalcType.perKg
                                    : LotExpenseCalcType.fixed),
                            defaultAmount: exp.rate,
                          );
                        },
                        onRemoveCustomExpense: (index) {
                          setState(() => _customExpenses.removeAt(index));
                        },
                        totalPackages: totalPackages,
                        netWeight: netWeight,
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // Section B: Payment Details
                      PaymentDetailsStep(
                        isEmbedded: true,
                        netGoodsAmount: netGoodsAmount,
                        totalInwardExpenses: totalInwardExpenses,
                        advancePaidController: _advancePaidController,
                        remainingRentController: _remainingRentController,
                        paymentMode: _paymentMode,
                        onPaymentModeChanged: (mode) => setState(() => _paymentMode = mode),
                        paidAmountController: _paidAmountController,
                        referenceController: _referenceController,
                        notesController: _notesController,
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // Section C: Final Review Step
                      FinalReviewStep(
                        isEmbedded: true,
                        selectedProduct: _selectedProduct,
                        supplierName: supplierName,
                        entryNumber: _entryNumberController.text.trim(),
                        vehicleNumber: _vehicleNumberController.text.trim(),
                        lotDate: _lotDate,
                        lotNumber: _lotNumberPreview,
                        bagEntries: _bagEntries,
                        weightMode: _weightMode,
                        grossWeight: grossWeight,
                        tareWeight: tareWeight,
                        netWeight: netWeight,
                        rateBasis: _rateBasis,
                        purchaseRate: purchaseRate,
                        sellingRate: sellingRate,
                        discountAmount: discountAmount,
                        netGoodsAmount: netGoodsAmount,
                        labourCharge: labourCharge,
                        transportCharge: transportCharge,
                        sangamCharge: sangamCharge,
                        mamoolCharge: mamoolCharge,
                        otherCharges: otherCharges,
                        customExpenses: _customExpenses,
                        totalInwardExpenses: totalInwardExpenses,
                        advancePaid: advancePaid,
                        remainingRent: remainingRent,
                        paidAmount: paidAmount,
                        paymentMode: _paymentMode,
                        paymentReference: _referenceController.text.trim(),
                        notes: _notesController.text.trim(),
                        onEditSection: (stepIndex) {
                          if (stepIndex <= 1) {
                            _goToStep(0);
                          } else if (stepIndex <= 4) {
                            _goToStep(1);
                          } else {
                            _goToStep(2);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: _currentStep == _stepTitles.length - 1
                  ? _buildFinalActionButtons(theme)
                  : _buildStepNavigationButtons(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNavigationButtons(AppThemeColors theme) {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.text,
                side: BorderSide(color: theme.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == 0 ? 'Next: Bags & Weight' : 'Next: Charges & Review',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPreviewDialog(AppThemeColors theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.visibility_outlined, color: theme.primary, size: 22),
            const SizedBox(width: 8),
            Text('Lot Overview Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.text)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${_selectedProduct?.name ?? "Agricultural Produce"}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.text)),
              const SizedBox(height: 4),
              Text('Lot Number: $_lotNumberPreview', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text('Party/Supplier: ${ref.read(appRepositoryProvider).getSupplier(_selectedSupplierId ?? "")?.name ?? "General Supplier"}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text('Total Packages: $totalPackages bags', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text('Net Consignment Weight: ${netWeight.toStringAsFixed(1)} Kg', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text('Goods Value: ${AppFormatters.currency(netGoodsAmount)}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text('Total Mandi Charges: ${AppFormatters.currency(totalInwardExpenses)}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              const Divider(height: 16),
              Text('Total Consignment Cost: ${AppFormatters.currency(netGoodsAmount + totalInwardExpenses)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary)),
              Text('Paid Amount: ${AppFormatters.currency(advancePaid + paidAmount)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.text)),
              Text('Balance Due: ${AppFormatters.currency((netGoodsAmount + totalInwardExpenses - (advancePaid + paidAmount)).clamp(0.0, double.infinity))}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveLot(createAnother: false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary, foregroundColor: Colors.white),
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalActionButtons(AppThemeColors theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => _saveLot(createAnother: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primary,
                  side: BorderSide(color: theme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save & New', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showPreviewDialog(theme),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.text,
                  side: BorderSide(color: theme.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Preview', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _saveLot(createAnother: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16),
                          SizedBox(width: 6),
                          Text('Save Lot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
