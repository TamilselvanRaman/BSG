import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_date_selector_banner.dart';
import '../../core/widgets/customer_picker_sheet.dart';
import '../../data/models/partner_models.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/app_repository.dart';

class ReceivedAmountScreen extends ConsumerStatefulWidget {
  final String? initialCustomerId;

  const ReceivedAmountScreen({super.key, this.initialCustomerId});

  @override
  ConsumerState<ReceivedAmountScreen> createState() => _ReceivedAmountScreenState();
}

class _ReceivedAmountScreenState extends ConsumerState<ReceivedAmountScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _paymentDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final result = await CustomerPickerSheet.show(
      context,
      allowCounterSale: false,
      selectedCustomerId: _selectedCustomerId,
    );

    if (result == null) return;

    if (result is Customer) {
      setState(() {
        _selectedCustomerId = result.id;
      });
    }
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
                  style: AppTypography.cardTitle.copyWith(color: theme.text),
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
      setState(() {
        _selectedCustomerId = created.id;
      });
      AppDialog.showSnackBar(context, 'Customer "${created.name}" created and selected');
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      AppDialog.showSnackBar(context, 'Please select a customer', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      AppDialog.showSnackBar(context, 'Payment amount must be greater than zero', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Find pending bills for this customer
      final pendingBills = ref
          .read(billsProvider)
          .where((b) => b.customerId == _selectedCustomerId && b.balanceDue > 0 && !b.isCancelled)
          .toList();

      // Allocate payment amount across pending bills
      double remainingToAllocate = amount;
      final allocations = <PaymentAllocation>[];

      for (final bill in pendingBills) {
        if (remainingToAllocate <= 0) break;
        final allocated = remainingToAllocate > bill.balanceDue ? bill.balanceDue : remainingToAllocate;
        allocations.add(PaymentAllocation(
          billId: bill.id,
          billNumber: bill.billNumber,
          allocatedAmount: allocated,
        ));
        remainingToAllocate -= allocated;
      }

      final payment = await ref.read(appRepositoryProvider).recordPayment(
        customerId: _selectedCustomerId!,
        date: _paymentDate,
        amount: amount,
        method: _paymentMethod,
        referenceNumber: _referenceController.text.trim().isNotEmpty ? _referenceController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        allocations: allocations,
      );

      if (mounted) {
        _showSuccessSheet(payment);
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Error recording payment: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet(Payment payment) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.surface,
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
            const Text('Payment Recorded Successfully', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text('Receipt Number: ${payment.receiptNumber}', style: AppTypography.bodySecondary),
            const SizedBox(height: 12),
            Text(
              AppFormatters.currency(payment.amount),
              style: AppTypography.amountLarge.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'View Customers',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/users');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Home',
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/home');
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
    final selectedCustomer = _selectedCustomerId != null
        ? ref.read(appRepositoryProvider).getCustomer(_selectedCustomerId!)
        : null;

    final customerPendingBills = selectedCustomer != null
        ? ref
            .watch(billsProvider)
            .where((b) => b.customerId == selectedCustomer.id && b.balanceDue > 0 && !b.isCancelled)
            .toList()
        : <Bill>[];

    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Received Amount', style: AppTypography.pageTitle.copyWith(color: theme.text)),
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
                label: 'Payment Receipt Date',
                selectedDate: _paymentDate,
                onDateChanged: (d) => setState(() => _paymentDate = d),
              ),

              // Card 1: Customer Selection & Current Outstanding
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1. Customer Details', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
                        InkWell(
                          onTap: _showNewCustomerDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add_alt_1_rounded, size: 14, color: theme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'New Customer',
                                  style: TextStyle(
                                    fontSize: 12,
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
                    Text(
                      'Customer / Buyer (Required)',
                      style: AppTypography.label.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tappable Customer Selector Box with green dropdown chevron
                    InkWell(
                      onTap: _pickCustomer,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedCustomer != null ? theme.primary : theme.border,
                            width: selectedCustomer != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedCustomer != null
                                    ? selectedCustomer.name
                                    : 'Select Customer (Buyer) from Directory...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selectedCustomer != null ? theme.text : theme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selectedCustomer != null && selectedCustomer.currentOutstanding > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Due: ${AppFormatters.currency(selectedCustomer.currentOutstanding)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 24,
                              color: theme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (selectedCustomer != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.primary.withValues(alpha: 0.15),
                              child: Text(
                                selectedCustomer.name.isNotEmpty ? selectedCustomer.name[0].toUpperCase() : 'C',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedCustomer.name,
                                    style: AppTypography.cardTitle.copyWith(color: theme.text, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [selectedCustomer.phone, if (selectedCustomer.city != null && selectedCustomer.city!.isNotEmpty) selectedCustomer.city].join(' • '),
                                    style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Outstanding Balance',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: selectedCustomer.currentOutstanding > 0 ? AppColors.error : theme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppFormatters.currency(selectedCustomer.currentOutstanding),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: selectedCustomer.currentOutstanding > 0 ? AppColors.error : theme.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card 2: Payment Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Payment Collection Details', style: AppTypography.sectionHeading),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Amount Received (₹) *',
                      hint: 'e.g. 5000',
                      controller: _amountController,
                      prefixText: '₹ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: AppValidators.positiveNumber,
                    ),
                    const SizedBox(height: 12),
                    const Text('Payment Mode', style: AppTypography.label),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PaymentMethod>(
                      isExpanded: true,
                      initialValue: _paymentMethod,
                      items: const [
                        DropdownMenuItem(value: PaymentMethod.cash, child: Text('Cash')),
                        DropdownMenuItem(value: PaymentMethod.upi, child: Text('UPI / Google Pay / PhonePe', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: PaymentMethod.bank, child: Text('Bank Transfer (NEFT/RTGS)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: PaymentMethod.cheque, child: Text('Cheque')),
                      ],
                      onChanged: (val) => setState(() => _paymentMethod = val ?? PaymentMethod.cash),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Reference / Transaction / UTR No',
                      hint: 'e.g. UPI Ref / Cheque No',
                      controller: _referenceController,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Remarks / Notes',
                      hint: 'Optional notes',
                      controller: _notesController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pending Bills to be allocated
              if (customerPendingBills.isNotEmpty) ...[
                const Text('Unpaid Credit Bills', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                ...customerPendingBills.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.billNumber, style: AppTypography.cardTitle),
                            Text('${b.productName} • ${AppFormatters.date(b.date)}', style: AppTypography.labelMuted),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(b.balanceDue),
                              style: AppTypography.cardTitle.copyWith(color: AppColors.warning),
                            ),
                            const Text('Pending Due', style: AppTypography.labelMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],

              AppButton(
                text: 'Record Payment & Settle Ledger',
                isLoading: _isLoading,
                onPressed: _submitPayment,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
