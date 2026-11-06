import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/payment.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final String? initialBillId;
  final String? initialCustomerId;

  const RecordPaymentScreen({
    super.key,
    this.initialBillId,
    this.initialCustomerId,
  });

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  String? _selectedBillId;
  late TextEditingController _amountCtrl;
  DateTime _paymentDate = DateTime.now();
  String _paymentMode = 'UPI';
  late TextEditingController _referenceCtrl;
  late TextEditingController _notesCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _selectedBillId = widget.initialBillId;

    _amountCtrl = TextEditingController();
    _referenceCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedBillId != null) {
        final bill = ref.read(billsProvider).cast<Bill?>().firstWhere(
          (b) => b?.id == _selectedBillId,
          orElse: () => null,
        );
        if (bill != null) {
          setState(() {
            _selectedCustomerId = bill.customerId;
            _amountCtrl.text = bill.remainingBalance > 0
                ? bill.remainingBalance.toStringAsFixed(0)
                : '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onCustomerSelected(String customerId) {
    setState(() {
      _selectedCustomerId = customerId;
      _selectedBillId = null;
      _amountCtrl.text = '';
    });
  }

  void _onBillSelected(String? billId) {
    setState(() {
      _selectedBillId = billId;
      if (billId != null) {
        final bill = ref.read(billsProvider).cast<Bill?>().firstWhere(
          (b) => b?.id == billId,
          orElse: () => null,
        );
        if (bill != null && bill.remainingBalance > 0) {
          _amountCtrl.text = bill.remainingBalance.toStringAsFixed(0);
        }
      }
    });
  }

  double get _currentBalance {
    if (_selectedCustomerId == null) return 0.0;
    return ref.read(customerBalanceProvider(_selectedCustomerId!));
  }

  double get _enteredAmount {
    return double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
  }

  double get _balanceAfterPayment {
    return _currentBalance - _enteredAmount;
  }

  void _submitPayment() {
    if (_isSubmitting) return; // Prevent duplicate submission
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Buyer'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount must be greater than zero'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payment = Payment(
      id: 'pay-${const Uuid().v4().substring(0, 8)}',
      customerId: _selectedCustomerId!,
      goodsEntryId: null,
      billId: _selectedBillId,
      amount: _enteredAmount,
      paymentDate: _paymentDate,
      paymentMode: _paymentMode,
      paymentType: _selectedBillId != null ? PaymentType.billPayment : PaymentType.generalAdvance,
      reference: _referenceCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
    );

    ref.read(appStateProvider.notifier).recordPayment(payment);

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ${CurrencyFormatter.format(_enteredAmount)} recorded successfully!'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider).where((c) => c.customerType != CustomerType.seller).toList();
    final bills = ref.watch(billsProvider);
    final customerBills = _selectedCustomerId == null
        ? <Bill>[]
        : bills.where((b) => b.customerId == _selectedCustomerId && b.status != BillStatus.cancelled && b.status != BillStatus.paid).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Customer Payment'),
      ),
      body: ResponsiveContainer(
        maxWidth: 780,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Payment Details Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Details', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.md),

                    // Customer Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Buyer *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedCustomerId,
                          hint: const Text('Choose buyer'),
                          items: customers.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Text('${c.name} (${c.village})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _onCustomerSelected(val);
                          },
                          validator: (val) => val == null ? 'Please select a buyer' : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Bill Selection (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Allocate to Specific Bill (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String?>(
                          value: _selectedBillId,
                          hint: const Text('General buyer credit / No specific bill'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('General Account Credit (Unapplied Advance)'),
                            ),
                            ...customerBills.map((b) {
                              return DropdownMenuItem<String?>(
                                value: b.id,
                                child: Text('${b.billNumber} (Due: ${CurrencyFormatter.format(b.remainingBalance)})'),
                              );
                            }),
                          ],
                          onChanged: _onBillSelected,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Amount & Mode
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Payment Amount (₹) *',
                            hint: '0',
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.currency_rupee,
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter amount';
                              final n = double.tryParse(val.trim());
                              if (n == null || n <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Mode *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _paymentMode,
                                items: ['UPI', 'Cash', 'Bank Transfer', 'Cheque', 'Other'].map((mode) {
                                  return DropdownMenuItem(value: mode, child: Text(mode));
                                }).toList(),
                                onChanged: (val) => setState(() => _paymentMode = val ?? 'UPI'),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Date & Reference
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _paymentDate,
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) setState(() => _paymentDate = picked);
                                },
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    color: AppColors.cardSurface,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormatter.format(_paymentDate), style: const TextStyle(fontSize: 14)),
                                      const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CustomTextField(
                            label: 'Reference / UTR / Txn ID',
                            hint: 'e.g. UPI/12345/6789',
                            controller: _referenceCtrl,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    CustomTextField(
                      label: 'Payment Notes',
                      hint: 'e.g. Part payment for week ending Friday',
                      controller: _notesCtrl,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Live Balance Comparison Card
              if (_selectedCustomerId != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Balance Impact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryGreenDark)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Buyer Balance Before Payment:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text(
                            CurrencyFormatter.format(_currentBalance),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _currentBalance > 0 ? AppColors.danger : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Amount Applied:', style: TextStyle(fontSize: 13, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
                          Text(
                            '- ${CurrencyFormatter.format(_enteredAmount)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accentGreen),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _balanceAfterPayment < 0
                                ? 'Projected Advance / Credit Surplus:'
                                : 'Projected Remaining Due:',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            CurrencyFormatter.format(_balanceAfterPayment.abs()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _balanceAfterPayment > 0
                                  ? AppColors.danger
                                  : _balanceAfterPayment < 0
                                      ? AppColors.primaryGreen
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      isOutlined: true,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Submit Payment',
                      isLoading: _isSubmitting,
                      onPressed: _submitPayment,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    ),
  );
}
}
