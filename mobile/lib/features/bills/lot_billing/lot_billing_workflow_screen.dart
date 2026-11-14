import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/lot_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../services/bill_calculation_engine.dart';
import 'screens/lot_selection_screen.dart';
import 'screens/bag_management_screen.dart';
import 'screens/additional_charges_screen.dart';
import 'screens/final_bill_preview_screen.dart';

class LotBillingWorkflowScreen extends ConsumerStatefulWidget {
  final String? initialLotId;
  final String? initialCustomerId;

  const LotBillingWorkflowScreen({
    super.key,
    this.initialLotId,
    this.initialCustomerId,
  });

  @override
  ConsumerState<LotBillingWorkflowScreen> createState() => _LotBillingWorkflowScreenState();
}

class _LotBillingWorkflowScreenState extends ConsumerState<LotBillingWorkflowScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Lot Selection',
    'Bags & Weights',
    'Additional Charges',
    'Final Bill Preview',
  ];

  // --- Step 1 State: Lot & Buyer ---
  Lot? _selectedLot;
  DateTime _billDate = DateTime.now();
  final TextEditingController _customerNameController = TextEditingController(text: 'Counter Cash Buyer');
  final TextEditingController _customerPhoneController = TextEditingController();
  String? _selectedCustomerId;
  BillType _billType = BillType.cash;

  // --- Step 2 State: Bags & Quantity ---
  List<BagRowCalculation> _bags = [];
  PricingMode _pricingMode = PricingMode.common;
  double _commonRate = 0.0;
  double _defaultBagWeight = 50.0;

  // --- Step 3 State: Charges ---
  final TextEditingController _transportFeeController = TextEditingController(text: '0');
  final TextEditingController _transportDescController = TextEditingController();
  final TextEditingController _labourFeeController = TextEditingController(text: '0');
  final TextEditingController _labourDescController = TextEditingController();
  final TextEditingController _mandiFeeController = TextEditingController(text: '0');
  final TextEditingController _mandiDescController = TextEditingController();
  List<BillExtraCharge> _extraCharges = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;

    // Load initial lot if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLotId != null) {
        final lot = ref.read(appRepositoryProvider).getLot(widget.initialLotId!);
        if (lot != null) {
          _onLotChosen(lot);
        }
      }
    });

    // Default sample 5 bags for quick verification
    _bags = BillCalculationEngine.generateBagRows(
      count: 5,
      defaultWeight: 50.0,
      defaultRate: 25.0,
    );
    _commonRate = 25.0;
  }

  void _onLotChosen(Lot lot) {
    setState(() {
      _selectedLot = lot;
      if (lot.costRate > 0) {
        _commonRate = lot.costRate;
      }
      // Set initial bags based on lot goodsCount or default 5
      final count = (lot.goodsCount > 0 && lot.goodsCount <= 50) ? lot.goodsCount : 5;
      final avgWt = (lot.remainingQuantity > 0 && count > 0) ? (lot.remainingQuantity / count) : 50.0;
      _defaultBagWeight = double.parse(avgWt.toStringAsFixed(1));

      _bags = BillCalculationEngine.generateBagRows(
        count: count,
        defaultWeight: _defaultBagWeight,
        defaultRate: _commonRate,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _transportFeeController.dispose();
    _transportDescController.dispose();
    _labourFeeController.dispose();
    _labourDescController.dispose();
    _mandiFeeController.dispose();
    _mandiDescController.dispose();
    super.dispose();
  }

  BillCalculationResult get calculationResult {
    final transport = double.tryParse(_transportFeeController.text) ?? 0.0;
    final labour = double.tryParse(_labourFeeController.text) ?? 0.0;
    final mandi = double.tryParse(_mandiFeeController.text) ?? 0.0;

    return BillCalculationEngine.compute(
      bags: _bags,
      transportFee: transport,
      labourFee: labour,
      mandiFee: mandi,
      extraCharges: _extraCharges,
    );
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _stepTitles.length) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep(int step) {
    final theme = context.appTheme;

    switch (step) {
      case 0:
        if (_selectedLot == null) {
          _showSnackbar('Please select an available lot to proceed', theme.error);
          return false;
        }
        return true;
      case 1:
        if (_bags.isEmpty) {
          _showSnackbar('Please add at least 1 bag to the consignment', theme.error);
          return false;
        }
        final hasZeroWeight = _bags.any((b) => b.weight <= 0);
        if (hasZeroWeight) {
          _showSnackbar('All bags must have a positive weight (> 0 KG)', theme.error);
          return false;
        }
        final hasZeroRate = _bags.any((b) => b.rate <= 0);
        if (hasZeroRate) {
          _showSnackbar('All bags must have a rate per KG (> 0)', theme.error);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _onNext() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _stepTitles.length - 1) {
        _goToStep(_currentStep + 1);
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

  void _showSnackbar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSaveFinalBill() async {
    if (_isSubmitting) return;

    if (_selectedLot == null) {
      _showSnackbar('Error: No lot selected', context.appTheme.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(appRepositoryProvider);
      final res = calculationResult;

      final billItems = _bags.map((b) => b.toBillBagItem()).toList();

      final newBill = await repo.createLotBasedBill(
        lotId: _selectedLot!.id,
        date: _billDate,
        type: _billType,
        customerId: _selectedCustomerId,
        customerName: _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : 'Counter Cash Buyer',
        customerPhone: _customerPhoneController.text.trim(),
        bagItems: billItems,
        transportFee: res.transportFee,
        labourFee: res.labourFee,
        mandiFee: res.mandiFee,
        extraCharges: _extraCharges,
        amountReceived: _billType == BillType.cash ? res.grandTotal : 0.0,
        sellerName: _selectedLot!.supplierName,
        lotRefNumber: _selectedLot!.entryNumber,
      );

      if (!mounted) return;

      _showSnackbar('Bill ${newBill.billNumber} generated and saved successfully!', context.appTheme.success);

      // Navigate to details or pop
      context.pushReplacement('/bills/${newBill.id}');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackbar('Failed to save bill: $e', context.appTheme.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lot-Based Goods Billing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.text),
            ),
            Text(
              _stepTitles[_currentStep],
              style: TextStyle(fontSize: 11, color: theme.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.text),
          onPressed: _onBack,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: theme.error)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 4-Step Progress Indicator Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: List.generate(_stepTitles.length, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (index <= _currentStep) {
                        _goToStep(index);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? theme.primary
                                    : isCompleted
                                        ? theme.success
                                        : theme.accent,
                                border: Border.all(
                                  color: isCurrent || isCompleted ? Colors.transparent : theme.border,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isCurrent ? Colors.white : theme.textSecondary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _stepTitles[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrent ? theme.primary : theme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 3.5,
                          margin: EdgeInsets.only(right: index == _stepTitles.length - 1 ? 0 : 4),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.primary
                                : isCompleted
                                    ? theme.success
                                    : theme.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main Step Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Controlled step progression
              children: [
                // Screen 01: Lot Selection
                LotSelectionScreen(
                  selectedLot: _selectedLot,
                  onLotSelected: (lot) => _onLotChosen(lot),
                  billDate: _billDate,
                  onBillDateChanged: (d) => setState(() => _billDate = d),
                  customerNameController: _customerNameController,
                  customerPhoneController: _customerPhoneController,
                  selectedCustomerId: _selectedCustomerId,
                  onCustomerSelected: (id) => setState(() {
                    _selectedCustomerId = id;
                    _billType = id != null ? BillType.credit : BillType.cash;
                  }),
                ),

                // Screen 02: Dynamic Bag & Weight Table
                BagManagementScreen(
                  bags: _bags,
                  onBagsChanged: (updated) => setState(() => _bags = updated),
                  pricingMode: _pricingMode,
                  onPricingModeChanged: (mode) => setState(() => _pricingMode = mode),
                  commonRate: _commonRate,
                  onCommonRateChanged: (rate) => setState(() => _commonRate = rate),
                  defaultBagWeight: _defaultBagWeight,
                  onDefaultBagWeightChanged: (w) => setState(() => _defaultBagWeight = w),
                ),

                // Screen 03: Additional Charges
                AdditionalChargesScreen(
                  goodsAmount: calculationResult.goodsAmount,
                  transportFeeController: _transportFeeController,
                  transportDescController: _transportDescController,
                  labourFeeController: _labourFeeController,
                  labourDescController: _labourDescController,
                  mandiFeeController: _mandiFeeController,
                  mandiDescController: _mandiDescController,
                  extraCharges: _extraCharges,
                  onExtraChargesChanged: (list) => setState(() => _extraCharges = list),
                  onChanged: () => setState(() {}),
                ),

                // Screen 04: Automatic Final Bill Page
                FinalBillPreviewScreen(
                  lot: _selectedLot,
                  billDate: _billDate,
                  billNumberPreview: _billType == BillType.cash ? 'CB-2026-AUTOGEN' : 'CR-2026-AUTOGEN',
                  customerName: _customerNameController.text.trim().isNotEmpty
                      ? _customerNameController.text.trim()
                      : 'Counter Cash Buyer',
                  customerPhone: _customerPhoneController.text.trim(),
                  billType: _billType,
                  bags: _bags,
                  calculationResult: calculationResult,
                  extraCharges: _extraCharges,
                  onBackToEdit: () => _goToStep(1),
                  onSaveBill: _handleSaveFinalBill,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          ),

          // Bottom Action Bar (Only on Steps 0, 1, 2; Step 3 has its own action buttons)
          if (_currentStep < _stepTitles.length - 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(top: BorderSide(color: theme.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
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
                              _currentStep == 2 ? 'GENERATE BILL' : 'Continue',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
