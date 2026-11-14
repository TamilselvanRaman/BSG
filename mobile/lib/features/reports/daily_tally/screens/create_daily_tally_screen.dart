import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_date_selector_banner.dart';
import '../../../../data/models/bill_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/repositories/app_repository.dart';
import '../models/daily_tally_model.dart';

class CreateDailyTallyScreen extends ConsumerStatefulWidget {
  const CreateDailyTallyScreen({super.key});

  @override
  ConsumerState<CreateDailyTallyScreen> createState() => _CreateDailyTallyScreenState();
}

class _CreateDailyTallyScreenState extends ConsumerState<CreateDailyTallyScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _date = DateTime.now();
  final _openingCashCtrl = TextEditingController(text: '15000');

  // Cash Receipts
  final _cashSalesCtrl = TextEditingController(text: '0');
  final _outstandingReceivedCtrl = TextEditingController(text: '0');
  final _otherCashReceivedCtrl = TextEditingController(text: '0');
  final _gpay1Ctrl = TextEditingController(text: '0');
  final _gpay2Ctrl = TextEditingController(text: '0');

  // Expenses Breakdown
  final _labourCtrl = TextEditingController(text: '0');
  final _transportCtrl = TextEditingController(text: '0');
  final _rentCtrl = TextEditingController(text: '0');
  final _utilitiesCtrl = TextEditingController(text: '0');
  final _teaCtrl = TextEditingController(text: '0');
  final _otherExpCtrl = TextEditingController(text: '0');

  // Other Transactions
  final _bankDepositCtrl = TextEditingController(text: '0');
  final _otherInflowCtrl = TextEditingController(text: '0');
  final _otherOutflowCtrl = TextEditingController(text: '0');

  // Cash Verification
  final _actualCashCtrl = TextEditingController(text: '0');
  final _pettyCashCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  final List<TallyPartyPayment> _partyPayments = [];

  @override
  void initState() {
    super.initState();
    // Auto populate on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchData();
    });
  }

  @override
  void dispose() {
    _openingCashCtrl.dispose();
    _cashSalesCtrl.dispose();
    _outstandingReceivedCtrl.dispose();
    _otherCashReceivedCtrl.dispose();
    _gpay1Ctrl.dispose();
    _gpay2Ctrl.dispose();
    _labourCtrl.dispose();
    _transportCtrl.dispose();
    _rentCtrl.dispose();
    _utilitiesCtrl.dispose();
    _teaCtrl.dispose();
    _otherExpCtrl.dispose();
    _bankDepositCtrl.dispose();
    _otherInflowCtrl.dispose();
    _otherOutflowCtrl.dispose();
    _actualCashCtrl.dispose();
    _pettyCashCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.trim()) ?? 0.0;
  }

  void _autoFetchData() {
    final repo = ref.read(appRepositoryProvider);
    final allTallies = repo.getDailyTallies();
    final allBills = repo.getBills();
    final allExpenses = repo.getExpenses();

    // 1. Opening Cash = Yesterday's closing cash if exists
    final yesterday = _date.subtract(const Duration(days: 1));
    final prevTally = allTallies.where((t) =>
        t.date.year == yesterday.year &&
        t.date.month == yesterday.month &&
        t.date.day == yesterday.day).firstOrNull;

    if (prevTally != null) {
      _openingCashCtrl.text = prevTally.actualCashCounted.toStringAsFixed(0);
    }

    // 2. Today's Cash Sales from bills
    final todayBills = allBills.where((b) =>
        b.date.year == _date.year &&
        b.date.month == _date.month &&
        b.date.day == _date.day &&
        !b.isCancelled);

    final todayCashSales = todayBills
        .where((b) => b.type == BillType.cash)
        .fold(0.0, (acc, b) => acc + b.amountReceived);
    _cashSalesCtrl.text = todayCashSales.toStringAsFixed(0);

    // 2b. Outstanding Cash Receipts from customer payments
    final todayPayments = repo.getPayments().where((p) =>
        p.date.year == _date.year &&
        p.date.month == _date.month &&
        p.date.day == _date.day);
    final todayOutstandingCash = todayPayments
        .where((p) => p.method == PaymentMethod.cash)
        .fold(0.0, (acc, p) => acc + p.amount);
    final todayOutstandingUpi = todayPayments
        .where((p) => p.method == PaymentMethod.upi)
        .fold(0.0, (acc, p) => acc + p.amount);

    _outstandingReceivedCtrl.text = todayOutstandingCash.toStringAsFixed(0);
    if (todayOutstandingUpi > 0 && _parse(_gpay1Ctrl) == 0) {
      _gpay1Ctrl.text = todayOutstandingUpi.toStringAsFixed(0);
    }

    // 3. Today's Expenses by Category
    final todayExpenses = allExpenses.where((e) =>
        e.date.year == _date.year &&
        e.date.month == _date.month &&
        e.date.day == _date.day);

    double labour = 0;
    double transport = 0;
    double rent = 0;
    double utilities = 0;
    double tea = 0;
    double other = 0;

    for (final exp in todayExpenses) {
      final cat = exp.category.toLowerCase().trim();
      if (cat.contains('labour') || cat.contains('coolie') || cat.contains('loading')) {
        labour += exp.amount;
      } else if (cat.contains('transport') || cat.contains('freight') || cat.contains('lorry')) {
        transport += exp.amount;
      } else if (cat.contains('rent')) {
        rent += exp.amount;
      } else if (cat.contains('utilit') || cat.contains('power') || cat.contains('eb')) {
        utilities += exp.amount;
      } else if (cat.contains('tea') || cat.contains('refresh')) {
        tea += exp.amount;
      } else {
        other += exp.amount;
      }
    }

    _labourCtrl.text = labour.toStringAsFixed(0);
    _transportCtrl.text = transport.toStringAsFixed(0);
    _rentCtrl.text = rent.toStringAsFixed(0);
    _utilitiesCtrl.text = utilities.toStringAsFixed(0);
    _teaCtrl.text = tea.toStringAsFixed(0);
    _otherExpCtrl.text = other.toStringAsFixed(0);

    // Auto calculate expected cash counted
    final available = _parse(_openingCashCtrl) + todayCashSales + todayOutstandingCash;
    final totalExp = labour + transport + rent + utilities + tea + other;
    _actualCashCtrl.text = (available - totalExp).clamp(0, double.infinity).toStringAsFixed(0);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-fetched today\'s bills and operating expenses successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showExpenseTransactionsSheet([String? categoryFilter]) {
    final theme = context.appTheme;
    final allExpenses = ref.read(appRepositoryProvider).getExpenses().where((e) =>
        e.date.year == _date.year &&
        e.date.month == _date.month &&
        e.date.day == _date.day).toList();

    final filtered = categoryFilter == null
        ? allExpenses
        : allExpenses.where((e) => e.category.toLowerCase().contains(categoryFilter.toLowerCase())).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categoryFilter != null ? '$categoryFilter Vouchers' : 'Today\'s Operating Expense Vouchers',
                    style: AppTypography.cardTitle.copyWith(color: theme.text),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No expense transactions recorded for this category today.',
                        style: TextStyle(color: theme.textMuted)),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => Divider(color: theme.border, height: 1),
                    itemBuilder: (context, i) {
                      final exp = filtered[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.receipt_outlined, color: theme.primary, size: 18),
                        ),
                        title: Text(exp.title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.text)),
                        subtitle: Text('${exp.category}${exp.paidTo != null ? " • ${exp.paidTo}" : ""}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                        trailing: Text(
                          AppFormatters.currency(exp.amount),
                          style: TextStyle(fontWeight: FontWeight.w700, color: theme.error, fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPartyPaymentDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    TallyPaymentMode mode = TallyPaymentMode.cash;

    final repo = ref.read(appRepositoryProvider);
    final partySuggestions = {
      ...repo.getSuppliers().map((s) => s.name),
      ...repo.getCustomers().map((c) => c.name),
    }.toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = context.appTheme;
          return AlertDialog(
            backgroundColor: theme.surface,
            title: Text('Add Party Payment', style: AppTypography.cardTitle.copyWith(color: theme.text)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: nameCtrl,
                    label: 'Party Name (Farmer / Supplier / Customer)',
                    hint: 'e.g. Kaveri Farms',
                  ),
                  if (partySuggestions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: partySuggestions.take(6).map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ActionChip(
                              label: Text(p, style: TextStyle(fontSize: 11, color: theme.text)),
                              backgroundColor: theme.accent,
                              side: BorderSide(color: theme.border),
                              onPressed: () {
                                setDialogState(() {
                                  nameCtrl.text = p;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: amountCtrl,
                    label: 'Amount (₹)',
                    keyboardType: TextInputType.number,
                    hint: 'e.g. 5000',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TallyPaymentMode>(
                    initialValue: mode,
                    dropdownColor: theme.surface,
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      labelText: 'Payment Mode',
                      labelStyle: TextStyle(color: theme.textSecondary),
                    ),
                    items: TallyPaymentMode.values.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.displayName, style: TextStyle(color: theme.text)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => mode = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: refCtrl,
                    label: 'Reference / Remarks (Optional)',
                    hint: 'e.g. Advance settlement',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (name.isEmpty || amount <= 0) return;

                  setState(() {
                    _partyPayments.add(
                      TallyPartyPayment(
                        id: 'tpp_${DateTime.now().millisecondsSinceEpoch}',
                        partyName: name,
                        amount: amount,
                        mode: mode,
                        reference: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: Text('Add Payment', style: TextStyle(color: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveTally() {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(appRepositoryProvider);
    final tally = repo.createDailyTally(
      date: _date,
      openingCash: _parse(_openingCashCtrl),
      cashSales: _parse(_cashSalesCtrl),
      outstandingReceived: _parse(_outstandingReceivedCtrl),
      otherCashReceived: _parse(_otherCashReceivedCtrl),
      gpay1Received: _parse(_gpay1Ctrl),
      gpay2Received: _parse(_gpay2Ctrl),
      labourExpense: _parse(_labourCtrl),
      transportExpense: _parse(_transportCtrl),
      rentExpense: _parse(_rentCtrl),
      utilitiesExpense: _parse(_utilitiesCtrl),
      teaRefreshmentsExpense: _parse(_teaCtrl),
      otherExpense: _parse(_otherExpCtrl),
      partyPayments: _partyPayments,
      bankDeposit: _parse(_bankDepositCtrl),
      otherCashInflow: _parse(_otherInflowCtrl),
      otherCashOutflow: _parse(_otherOutflowCtrl),
      actualCashCounted: _parse(_actualCashCtrl),
      pettyCashInHand: _parse(_pettyCashCtrl),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily Tally ${tally.tallyNumber} recorded successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    // Live mathematical calculations
    final openingCash = _parse(_openingCashCtrl);
    final cashSales = _parse(_cashSalesCtrl);
    final outstanding = _parse(_outstandingReceivedCtrl);
    final otherCashRec = _parse(_otherCashReceivedCtrl);
    final otherInflow = _parse(_otherInflowCtrl);

    final totalAvailableCash = openingCash + cashSales + outstanding + otherCashRec + otherInflow;

    final totalExpenses = _parse(_labourCtrl) +
        _parse(_transportCtrl) +
        _parse(_rentCtrl) +
        _parse(_utilitiesCtrl) +
        _parse(_teaCtrl) +
        _parse(_otherExpCtrl);

    final totalCashPartyPay = _partyPayments.where((p) => p.isCash).fold(0.0, (acc, p) => acc + p.amount);
    final bankDeposit = _parse(_bankDepositCtrl);
    final otherOutflow = _parse(_otherOutflowCtrl);

    final totalCashOutflow = totalExpenses + totalCashPartyPay + bankDeposit + otherOutflow;
    final expectedClosingCash = totalAvailableCash - totalCashOutflow;
    final actualCashCounted = _parse(_actualCashCtrl);
    final cashDiff = actualCashCounted - expectedClosingCash;
    final isBalanced = cashDiff.abs() < 0.01;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Create Daily Tally', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sync_rounded, color: theme.primary),
            tooltip: 'Auto-fetch Today\'s Data',
            onPressed: _autoFetchData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.border, height: 1),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expected Closing Cash', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                      Text(AppFormatters.currency(expectedClosingCash), style: AppTypography.cardTitle.copyWith(color: theme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isBalanced
                          ? theme.success.withValues(alpha: 0.15)
                          : (cashDiff > 0 ? theme.info.withValues(alpha: 0.15) : theme.error.withValues(alpha: 0.15)),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Text(
                      isBalanced
                          ? 'BALANCED'
                          : (cashDiff > 0 ? 'SURPLUS +${AppFormatters.currency(cashDiff)}' : 'SHORTAGE ${AppFormatters.currency(cashDiff)}'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isBalanced ? theme.success : (cashDiff > 0 ? theme.info : theme.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Save Daily Tally',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveTally,
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Selector Banner with Auto-fetch
            AppDateSelectorBanner(
              label: 'Tally Date',
              selectedDate: _date,
              onDateChanged: (d) {
                setState(() => _date = d);
                _autoFetchData();
              },
            ),

            const SizedBox(height: 14),

            // Section 1: Opening Balance
            _buildSectionHeader('1. Opening Cash', Icons.lock_open_rounded, theme),
            AppCard(
              child: AppTextField(
                controller: _openingCashCtrl,
                label: 'Yesterday Closing Cash (₹)',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Cash Receipts
            _buildSectionHeader('2. Cash Receipts & Inflows', Icons.call_received_rounded, theme),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _cashSalesCtrl,
                    label: 'Today\'s Cash Sales (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _outstandingReceivedCtrl,
                    label: 'Outstanding Collections (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _otherCashReceivedCtrl,
                    label: 'Other Cash Received (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _otherInflowCtrl,
                    label: 'Other Cash Inflow (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: theme.border),
                  const SizedBox(height: 10),
                  Text(
                    'Digital Receipts (UPI / GPay - Not in physical cash)',
                    style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _gpay1Ctrl,
                          label: 'GPay 1 (₹)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _gpay2Ctrl,
                          label: 'GPay 2 (₹)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 3: Operating Expenses
            _buildSectionHeader(
              '3. Operating Expenses',
              Icons.outbox_rounded,
              theme,
              trailing: InkWell(
                onTap: () => _showExpenseTransactionsSheet(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 14, color: theme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'View Vouchers',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary),
                    ),
                  ],
                ),
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _labourCtrl,
                          label: 'Labour (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _transportCtrl,
                          label: 'Transport (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _rentCtrl,
                          label: 'Store Rent (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _utilitiesCtrl,
                          label: 'Utilities (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _teaCtrl,
                          label: 'Tea & Refreshments (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _otherExpCtrl,
                          label: 'Other Expenses (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 4: Party Payments
            _buildSectionHeader('4. Party Payments', Icons.people_outline_rounded, theme),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_partyPayments.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No party payments recorded.', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                    ),
                  ] else ...[
                    ..._partyPayments.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(p.partyName, style: AppTypography.cardTitle.copyWith(color: theme.text, fontSize: 13.5)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: p.isCash ? theme.accent : Colors.purple.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          p.mode.displayName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: p.isCash ? theme.primary : Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (p.reference != null && p.reference!.isNotEmpty)
                                    Text(p.reference!, style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(AppFormatters.currency(p.amount), style: TextStyle(color: theme.text, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                    onPressed: () => setState(() => _partyPayments.remove(p)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                  AppButton(
                    text: '+ Add Party Payment',
                    variant: ButtonVariant.outline,
                    height: 38,
                    onPressed: _addPartyPaymentDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 5: Other Transactions
            _buildSectionHeader('5. Bank & Other Transactions', Icons.account_balance_outlined, theme),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _bankDepositCtrl,
                    label: 'Bank Cash Deposit (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _otherOutflowCtrl,
                    label: 'Other Cash Outflow (₹)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 6: Cash Counting & Verification
            _buildSectionHeader('6. Physical Cash Verification', Icons.verified_user_outlined, theme),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _actualCashCtrl,
                          label: 'Actual Cash Counted (₹)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.calculate_rounded, color: theme.primary),
                        tooltip: 'Open Denomination Calculator',
                        onPressed: () async {
                          final result = await context.push<double>('/reports/daily-tally/reconciliation');
                          if (result != null) {
                            setState(() {
                              _actualCashCtrl.text = result.toStringAsFixed(0);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _pettyCashCtrl,
                    label: 'Petty Cash in Hand (₹)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _notesCtrl,
                    label: 'Tally Notes & Remarks (Optional)',
                    maxLines: 2,
                    hint: 'e.g. Verified by cash counter staff',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, AppThemeColors theme, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.primary),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.sectionHeading.copyWith(color: theme.text, fontSize: 14.5)),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
