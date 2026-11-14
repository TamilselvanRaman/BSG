import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_date_selector_banner.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/app_repository.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Labour',
    'Transport',
    'Rent',
    'Utilities',
    'Tea & Refreshments',
    'Maintenance',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateExpenseDialog() {
    showDialog(
      context: context,
      builder: (_) => const _CreateExpenseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);

    final filtered = expenses.where((exp) {
      if (_selectedCategory != 'All' && exp.category != _selectedCategory) return false;
      if (_searchQuery.isEmpty) return true;
      return exp.title.toLowerCase().contains(_searchQuery) ||
          exp.expenseNumber.toLowerCase().contains(_searchQuery) ||
          (exp.paidTo?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    final theme = context.appTheme;
    final totalExpenseAmount = filtered.fold<double>(0.0, (acc, item) => acc + item.amount);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Expenses', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        actions: [
          IconButton(
            icon: Icon(Icons.calculate_outlined, color: theme.primary),
            tooltip: 'Daily Cash Tally',
            onPressed: () => context.push('/reports/daily-tally'),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.text),
            tooltip: 'Add Expense',
            onPressed: _openCreateExpenseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Expense Header Card
          Container(
            color: theme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Expense', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                        Text(AppFormatters.currency(totalExpenseAmount), style: AppTypography.amountLarge.copyWith(color: theme.text)),
                      ],
                    ),
                    AppButton(
                      text: 'Add Expense',
                      icon: Icons.add_rounded,
                      isFullWidth: false,
                      height: 42,
                      onPressed: _openCreateExpenseDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: theme.text),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search expense title or payee...',
                    hintStyle: TextStyle(color: theme.textMuted),
                    prefixIcon: Icon(Icons.search, size: 20, color: theme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                // Category horizontal chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.primary : theme.accent,
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white)
                                    : theme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Expenses List
          Expanded(
            child: filtered.isEmpty
                ? AppEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No Expenses Recorded',
                    description: 'Keep track of daily market loading, tea, transport and store maintenance.',
                    actionText: 'Add Expense',
                    onAction: _openCreateExpenseDialog,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exp = filtered[index];
                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Center(
                                child: Icon(Icons.outbox_rounded, size: 20, color: theme.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exp.title,
                                          style: AppTypography.cardTitle.copyWith(
                                            color: theme.text,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppFormatters.currency(exp.amount),
                                        style: AppTypography.cardTitle.copyWith(
                                          color: theme.text,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      AppBadge(label: exp.category, variant: BadgeVariant.neutral),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${AppFormatters.date(exp.date)}${exp.paidTo != null ? ' • Paid to ${exp.paidTo}' : ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (exp.notes != null && exp.notes!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      exp.notes!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySecondary.copyWith(
                                        color: theme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CreateExpenseDialog extends ConsumerStatefulWidget {
  const _CreateExpenseDialog();

  @override
  ConsumerState<_CreateExpenseDialog> createState() => _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends ConsumerState<_CreateExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidToController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Labour';
  final ExpensePaymentMethod _method = ExpensePaymentMethod.cash;
  DateTime _expenseDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categoryOptions = [
    'Labour',
    'Transport',
    'Rent',
    'Utilities',
    'Tea & Refreshments',
    'Maintenance',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _paidToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(appRepositoryProvider).createExpense(
        title: _titleController.text.trim(),
        category: _category,
        amount: double.parse(_amountController.text.trim()),
        date: _expenseDate,
        method: _method,
        paidTo: _paidToController.text.trim().isNotEmpty ? _paidToController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        AppDialog.showSnackBar(context, 'Expense recorded successfully');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Error creating expense: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Dialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Expense Entry', style: AppTypography.cardTitle.copyWith(color: theme.text)),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: theme.text),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppDateSelectorBanner(
                  label: 'Expense Date',
                  selectedDate: _expenseDate,
                  onDateChanged: (d) => setState(() => _expenseDate = d),
                ),
                AppTextField(
                  label: 'Expense Title *',
                  hint: 'e.g. Lorry Unloading Hamali',
                  controller: _titleController,
                  validator: (v) => AppValidators.required(v, 'Title is required'),
                ),
                const SizedBox(height: 12),
                const Text('Category', style: AppTypography.label),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _category,
                  items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _category = val ?? 'Labour'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Amount (₹) *',
                  hint: 'e.g. 500',
                  controller: _amountController,
                  prefixText: '₹ ',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: AppValidators.positiveNumber,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Paid To (Optional)',
                  hint: 'e.g. Loading workers team',
                  controller: _paidToController,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Notes / Remarks',
                  hint: 'Optional notes',
                  controller: _notesController,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save Expense',
                  isLoading: _isLoading,
                  onPressed: _submitExpense,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
