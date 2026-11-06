import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/customer.dart';
import 'print_bill_voucher_dialog.dart';
import 'widgets/bag_weights_entry_dialog.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final String? initialEntryId;
  final String? initialCustomerId;
  final String? initialLotNumber;
  final String? initialSellerId;

  const BillFormScreen({
    super.key,
    this.initialEntryId,
    this.initialCustomerId,
    this.initialLotNumber,
    this.initialSellerId,
  });

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  int _currentStep = 1; // 1: Bill To (Buyer Selection), 2: Lot & Weights, 3: Settlement

  // Step 1: Buyer Search & Selection
  final TextEditingController _buyerSearchCtrl = TextEditingController();
  String _buyerSearchQuery = '';
  String? _selectedCustomerId;

  // Step 2: Lot & Weighing Details
  late TextEditingController _billNoCtrl;
  final DateTime _billDate = DateTime.now();
  String? _selectedLotNumber;
  String? _selectedEntryId;
  late TextEditingController _commodityNameCtrl;
  late TextEditingController _varietyGradeCtrl;
  late TextEditingController _bagsCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _sellingRateCtrl;
  late TextEditingController _costRateCtrl;
  late TextEditingController _labourChargeCtrl;
  late TextEditingController _mandiFeeCtrl;

  // Step 3: Advance deduction & balance
  late TextEditingController _advanceDeductedCtrl;
  late TextEditingController _paidAmountCtrl;
  late TextEditingController _notesCtrl;
  bool _isSaving = false;
  List<double> _individualWeights = [];
  double _tareDeducted = 0.0;

  @override
  void initState() {
    super.initState();
    final nextNumber = 'BILL-2026-${(ref.read(billsProvider).length + 1).toString().padLeft(3, '0')}';
    _billNoCtrl = TextEditingController(text: nextNumber);
    _commodityNameCtrl = TextEditingController(text: 'Onion');
    _varietyGradeCtrl = TextEditingController(text: 'A(3)');
    _bagsCtrl = TextEditingController(text: '40');
    _weightCtrl = TextEditingController(text: '1000');
    _sellingRateCtrl = TextEditingController(text: '28');
    _costRateCtrl = TextEditingController(text: '24');
    _labourChargeCtrl = TextEditingController(text: '400');
    _mandiFeeCtrl = TextEditingController(text: '0');
    _advanceDeductedCtrl = TextEditingController(text: '0');
    _paidAmountCtrl = TextEditingController(text: '0');
    _notesCtrl = TextEditingController(text: 'Auction trade settlement');

    _selectedCustomerId = widget.initialCustomerId;
    _selectedEntryId = widget.initialEntryId;
    _selectedLotNumber = widget.initialLotNumber;

    if (_selectedCustomerId != null) {
      _currentStep = 2;
    }

    // Pre-populate from lot if passed
    if (_selectedLotNumber != null && _selectedLotNumber!.isNotEmpty) {
      final loads = ref.read(sellerLoadsProvider);
      final load = loads.where((l) => l.effectiveLotNumber == _selectedLotNumber).firstOrNull;
      if (load != null) {
        _commodityNameCtrl.text = load.commodity;
        _varietyGradeCtrl.text = load.varietyGrade;
        _bagsCtrl.text = load.unsoldBags > 0 ? load.unsoldBags.toInt().toString() : '40';
        _weightCtrl.text = (double.tryParse(_bagsCtrl.text) ?? 40 * 25).toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _buyerSearchCtrl.dispose();
    _billNoCtrl.dispose();
    _commodityNameCtrl.dispose();
    _varietyGradeCtrl.dispose();
    _bagsCtrl.dispose();
    _weightCtrl.dispose();
    _sellingRateCtrl.dispose();
    _costRateCtrl.dispose();
    _labourChargeCtrl.dispose();
    _mandiFeeCtrl.dispose();
    _advanceDeductedCtrl.dispose();
    _paidAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _calcSubtotal {
    final weight = double.tryParse(_weightCtrl.text) ?? 0.0;
    final rate = double.tryParse(_sellingRateCtrl.text) ?? 0.0;
    return weight * rate;
  }

  double get _calcLabour => double.tryParse(_labourChargeCtrl.text) ?? 0.0;
  double get _calcMandiFee => double.tryParse(_mandiFeeCtrl.text) ?? 0.0;
  double get _calcTotalAmount => _calcSubtotal + _calcLabour + _calcMandiFee;
  double get _calcAdvanceDeducted => double.tryParse(_advanceDeductedCtrl.text) ?? 0.0;
  double get _calcNetPayable {
    final net = _calcTotalAmount - _calcAdvanceDeducted;
    return net > 0 ? net : 0.0;
  }

  double get _calcPaidAmount => double.tryParse(_paidAmountCtrl.text) ?? 0.0;
  double get _calcRemainingBalance {
    final rem = _calcNetPayable - _calcPaidAmount;
    return rem > 0 ? rem : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider).where((c) => c.customerType != CustomerType.seller).toList();
    final selectedCustomer = customers.where((c) => c.id == _selectedCustomerId).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Add Bill',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          if (selectedCustomer != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedCustomer.name,
                    style: const TextStyle(color: AppColors.primaryGreenDark, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Stepper Header matching Photo 2: Step 1 (Bill To*) -> Step 2 -> Step 3
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStepPill(1, 'Bill To*', _currentStep == 1, _currentStep > 1),
                  const SizedBox(width: 8),
                  Container(width: 24, height: 2, color: _currentStep > 1 ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0)),
                  const SizedBox(width: 8),
                  _buildStepPill(2, 'Lot & Weighing', _currentStep == 2, _currentStep > 2),
                  const SizedBox(width: 8),
                  Container(width: 24, height: 2, color: _currentStep > 2 ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0)),
                  const SizedBox(width: 8),
                  _buildStepPill(3, 'Settlement', _currentStep == 3, false),
                ],
              ),
            ),
          ),

          // Main Step Body
          Expanded(
            child: _currentStep == 1
                ? _buildStep1BuyerSelection(customers)
                : _currentStep == 2
                    ? _buildStep2LotAndWeighing(selectedCustomer)
                    : _buildStep3Settlement(selectedCustomer),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int step, String label, bool isActive, bool isDone) {
    return GestureDetector(
      onTap: () {
        if (isDone || step < _currentStep) {
          setState(() => _currentStep = step);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2E7D32)
              : isDone
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone)
              const Icon(Icons.check, size: 13, color: Color(0xFF16A34A))
            else
              Text(
                'Step $step',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : isDone
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================
  // STEP 1: BILL TO (BUYER LIST MATCHING PHOTO 2)
  // ==========================================
  Widget _buildStep1BuyerSelection(List<Customer> customers) {
    final filtered = customers.where((c) {
      if (_buyerSearchQuery.isEmpty) return true;
      final q = _buyerSearchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.notes.toLowerCase().contains(q) ||
          c.village.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header & Search input matching Photo 2
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Bill To*', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text('Buyer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search input matching Photo 2: "Search by Name / Mobile / Short Code"
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _buyerSearchCtrl,
                  onChanged: (val) => setState(() => _buyerSearchQuery = val.trim()),
                  decoration: const InputDecoration(
                    hintText: 'Search by Name / Mobile / Short Code',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

        // Buyer List matching Photo 2 with green circle avatars
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 68, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final buyer = filtered[index];
              final isSelected = _selectedCustomerId == buyer.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCustomerId = buyer.id;
                    _currentStep = 2; // Advance to Step 2 Lot & Weighing!
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                  child: Row(
                    children: [
                      // Green Circle Silhouette Avatar matching Photo 2
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Color(0xFF16A34A), size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Buyer Name & Code matching Photo 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buyer.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              buyer.notes.isNotEmpty ? buyer.notes : 'Buyer - ${buyer.phone}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            if (buyer.village.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                buyer.village,
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: LOT & WEIGHING DETAILS
  // ==========================================
  Widget _buildStep2LotAndWeighing(Customer? buyer) {
    final sellerLoads = ref.watch(sellerLoadsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buyer Banner
          if (buyer != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billing To Selected Buyer:', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                        Text(buyer.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    child: const Text('Change Buyer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Lot Picker Dropdown / Chip
          const Text('Select Farmer Arrival Lot *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedLotNumber ?? (sellerLoads.isNotEmpty ? sellerLoads.first.effectiveLotNumber : null),
                hint: const Text('Choose Lot Number'),
                items: sellerLoads.map((load) {
                  return DropdownMenuItem<String>(
                    value: load.effectiveLotNumber,
                    child: Text(
                      '${load.effectiveLotNumber} • ${load.sellerName} (${load.commodity} ${load.varietyGrade})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final l = sellerLoads.firstWhere((x) => x.effectiveLotNumber == val);
                    setState(() {
                      _selectedLotNumber = val;
                      _commodityNameCtrl.text = l.commodity;
                      _varietyGradeCtrl.text = l.varietyGrade;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Commodity & Grade Inputs
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Commodity Name *',
                  controller: _commodityNameCtrl,
                  prefixIcon: Icons.eco_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'Variety / Grade *',
                  controller: _varietyGradeCtrl,
                  prefixIcon: Icons.grade_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Bags & Weight
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Bags to Bill (BG) *',
                  hint: '40',
                  controller: _bagsCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.all_inbox_outlined,
                  onChanged: (val) {
                    final bags = double.tryParse(val) ?? 0;
                    _weightCtrl.text = (bags * 25).toStringAsFixed(0);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'Net Weight (kg) *',
                  hint: '1000',
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.scale_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Option: Bag-by-Bag Weighing Entry (e.g. 10 bags means enter 10 bag weights)
          InkWell(
            onTap: () async {
              final bagCount = int.tryParse(_bagsCtrl.text) ?? 10;
              final res = await BagWeightsEntryDialog.show(
                context,
                initialBags: bagCount,
                initialWeights: _individualWeights.isNotEmpty ? _individualWeights : null,
              );
              if (res != null) {
                setState(() {
                  _bagsCtrl.text = res.totalBags.toString();
                  _weightCtrl.text = res.netWeight.toStringAsFixed(1);
                  _individualWeights = res.weights;
                  _tareDeducted = res.totalTare;
                });
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.scale_rounded, size: 20, color: Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _individualWeights.isNotEmpty
                              ? 'Bag-by-Bag Weighing Scale Active (${_individualWeights.length} Bags Recorded)'
                              : 'Enter Bag-by-Bag Weights (${_bagsCtrl.text.isEmpty ? "10" : _bagsCtrl.text} Bags)',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                        ),
                        Text(
                          _individualWeights.isNotEmpty
                              ? 'Gross: ${(_individualWeights.fold(0.0, (s, w) => s + w)).toStringAsFixed(1)} kg | Tare: -${_tareDeducted.toStringAsFixed(1)} kg | Net: ${_weightCtrl.text} kg'
                              : 'Tap to enter individual weights for each bag with auto tare deduction',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFF16A34A)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Auction Selling Rate & Hamali
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Selling Rate (₹/kg) *',
                  hint: '28',
                  controller: _sellingRateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.currency_rupee,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'Hamali / Labour (₹)',
                  hint: '400',
                  controller: _labourChargeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.handshake_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Live Calculation Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Produce Subtotal (${_weightCtrl.text} kg × ₹${_sellingRateCtrl.text}):',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(CurrencyFormatter.format(_calcSubtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Labour / Hamali Charge:',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(CurrencyFormatter.format(_calcLabour), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Lot Total Amount:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(_calcTotalAmount),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Next Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() => _currentStep = 3),
            child: const Text('Proceed to Settlement (Step 3) →', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3: SETTLEMENT, ADVANCE & PRINT BILL
  // ==========================================
  Widget _buildStep3Settlement(Customer? buyer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bill No: ${_billNoCtrl.text}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(DateFormatter.format(_billDate), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const Divider(height: 16),
                _buildSummaryLine('Buyer', buyer?.name ?? 'Wholesale Buyer'),
                _buildSummaryLine('Lot Number', _selectedLotNumber ?? 'Aditya-578'),
                _buildSummaryLine('Produce Variety', '${_commodityNameCtrl.text} (${_varietyGradeCtrl.text})'),
                _buildSummaryLine('Quantity', '${_bagsCtrl.text} Bags (${_weightCtrl.text} kg)'),
                _buildSummaryLine('Rate', '₹${_sellingRateCtrl.text} / kg'),
                const Divider(height: 16),
                _buildSummaryLine('Subtotal', CurrencyFormatter.format(_calcSubtotal)),
                _buildSummaryLine('Labour / Hamali', CurrencyFormatter.format(_calcLabour)),
                const Divider(height: 16),
                _buildSummaryLine('Gross Bill Total', CurrencyFormatter.format(_calcTotalAmount), isBold: true),
                const SizedBox(height: 4),
                _buildSummaryLine('Advance Deducted', '- ${CurrencyFormatter.format(_calcAdvanceDeducted)}', color: const Color(0xFF0284C7)),
                const Divider(height: 20),
                _buildSummaryLine('Net Payable Amount', CurrencyFormatter.format(_calcNetPayable), isBold: true, color: const Color(0xFF16A34A)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Advance & Cash Received Inputs
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Advance Deducted (₹)',
                  hint: '0',
                  controller: _advanceDeductedCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.account_balance_wallet_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'Cash Paid Now (₹)',
                  hint: '0',
                  controller: _paidAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.payments_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Buttons: Print Thermal Slip & Confirm Bill
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                  icon: const Icon(Icons.print_rounded, color: AppColors.primaryGreen),
                  label: const Text('Print Slip', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                  onPressed: () {
                    final tempBill = _createBillModel(buyer);
                    showDialog(
                      context: context,
                      builder: (_) => PrintBillVoucherDialog(
                        bill: tempBill,
                        customer: buyer ?? Customer(id: 'temp', name: 'Buyer', village: '', phone: '', customerType: CustomerType.buyer, openingBalance: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Confirm Bill', style: const TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: _isSaving ? null : () => _saveAndConfirmBill(buyer),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: const Color(0xFF475569))),
          Text(value, style: TextStyle(fontSize: 13.5, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Bill _createBillModel(Customer? buyer) {
    final weight = double.tryParse(_weightCtrl.text) ?? 1000.0;
    final rate = double.tryParse(_sellingRateCtrl.text) ?? 28.0;
    final bags = double.tryParse(_bagsCtrl.text) ?? 40.0;

    final item = BillItem(
      id: 'bi-${const Uuid().v4().substring(0, 8)}',
      description: '${_commodityNameCtrl.text} (${_varietyGradeCtrl.text})',
      weight: weight,
      quantity: bags,
      rate: rate,
      lineTotal: weight * rate,
    );

    return Bill(
      id: 'bill-${const Uuid().v4().substring(0, 8)}',
      billNumber: _billNoCtrl.text.trim(),
      customerId: buyer?.id ?? 'cust-aaa',
      goodsEntryId: _selectedEntryId,
      billDate: _billDate,
      items: [item],
      subtotal: weight * rate,
      labourCharge: _calcLabour,
      initialPaymentApplied: _calcAdvanceDeducted,
      otherPaymentsApplied: _calcPaidAmount,
      status: _calcRemainingBalance <= 0 ? BillStatus.paid : BillStatus.unpaid,
      createdAt: DateTime.now(),
    );
  }

  void _saveAndConfirmBill(Customer? buyer) {
    if (buyer == null && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Buyer first'), backgroundColor: AppColors.danger),
      );
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isSaving = true);

    final bill = _createBillModel(buyer);
    ref.read(appStateProvider.notifier).addBill(bill);

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill ${bill.billNumber} created successfully!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go('/bills/${bill.id}');
  }
}
