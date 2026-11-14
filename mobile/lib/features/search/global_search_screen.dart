import '../../core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/app_repository.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  AppThemeColors get theme => context.appTheme;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final bills = repo.getBills();
    final lots = repo.getLots();
    final customers = repo.getCustomers();
    final suppliers = repo.getSuppliers();
    final expenses = repo.getExpenses();

    final clean = _query.toLowerCase();

    final matchedBills = _query.isEmpty
        ? <Bill>[]
        : bills.where((b) =>
            b.billNumber.toLowerCase().contains(clean) ||
            b.customerName.toLowerCase().contains(clean) ||
            b.productName.toLowerCase().contains(clean)).toList();

    final matchedLots = _query.isEmpty
        ? []
        : lots.where((l) =>
            l.lotNumber.toLowerCase().contains(clean) ||
            l.productName.toLowerCase().contains(clean) ||
            l.supplierName.toLowerCase().contains(clean)).toList();

    final matchedCustomers = _query.isEmpty
        ? []
        : customers.where((c) =>
            c.name.toLowerCase().contains(clean) ||
            c.phone.contains(clean) ||
            (c.city?.toLowerCase().contains(clean) ?? false)).toList();

    final matchedSuppliers = _query.isEmpty
        ? []
        : suppliers.where((s) =>
            s.name.toLowerCase().contains(clean) ||
            s.phone.contains(clean) ||
            (s.city?.toLowerCase().contains(clean) ?? false)).toList();

    final matchedExpenses = _query.isEmpty
        ? []
        : expenses.where((e) =>
            e.title.toLowerCase().contains(clean) ||
            e.expenseNumber.toLowerCase().contains(clean) ||
            e.category.toLowerCase().contains(clean) ||
            (e.paidTo?.toLowerCase().contains(clean) ?? false)).toList();

    final totalMatches = matchedBills.length +
        matchedLots.length +
        matchedCustomers.length +
        matchedSuppliers.length +
        matchedExpenses.length;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (val) => setState(() => _query = val.trim()),
          decoration: InputDecoration(
            hintText: 'Search bills, lots, customers, suppliers...',
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('Search Anything in BSG', style: AppTypography.cardTitle),
                  const SizedBox(height: 4),
                  const Text('Enter bill no, customer, lot number or product name', style: AppTypography.bodySecondary),
                ],
              ),
            )
          : totalMatches == 0
              ? const Center(
                  child: Text('No matching records found', style: AppTypography.bodySecondary),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (matchedBills.isNotEmpty) ...[
                      const Text('Bills', style: AppTypography.sectionHeading),
                      const SizedBox(height: 8),
                      ...matchedBills.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppCard(
                              onTap: () => context.push('/bills/${b.id}'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(b.billNumber, style: AppTypography.cardTitle),
                                          const SizedBox(width: 6),
                                          AppBadge(
                                            label: b.type == BillType.cash ? 'CASH' : 'CREDIT',
                                            variant: b.type == BillType.cash ? BadgeVariant.info : BadgeVariant.warning,
                                          ),
                                        ],
                                      ),
                                      Text('${b.customerName} • ${b.productName}', style: AppTypography.bodySecondary),
                                    ],
                                  ),
                                  Text(AppFormatters.currency(b.totalAmount), style: AppTypography.cardTitle),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (matchedLots.isNotEmpty) ...[
                      const Text('Lots', style: AppTypography.sectionHeading),
                      const SizedBox(height: 8),
                      ...matchedLots.map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppCard(
                              onTap: () => context.push('/lots/${l.id}'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.lotNumber, style: AppTypography.cardTitle),
                                      Text('${l.productName} • ${l.supplierName}', style: AppTypography.bodySecondary),
                                    ],
                                  ),
                                  Text(
                                    AppFormatters.quantity(l.remainingQuantity, l.unit),
                                    style: AppTypography.cardTitle,
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (matchedCustomers.isNotEmpty) ...[
                      const Text('Customers', style: AppTypography.sectionHeading),
                      const SizedBox(height: 8),
                      ...matchedCustomers.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppCard(
                              onTap: () => context.push('/users/customer-ledger/${c.id}'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: AppTypography.cardTitle),
                                      Text(c.phone, style: AppTypography.bodySecondary),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Due', style: AppTypography.labelMuted),
                                      Text(
                                        AppFormatters.currency(c.currentOutstanding),
                                        style: AppTypography.cardTitle.copyWith(
                                          color: c.currentOutstanding > 0 ? AppColors.warning : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (matchedSuppliers.isNotEmpty) ...[
                      const Text('Suppliers', style: AppTypography.sectionHeading),
                      const SizedBox(height: 8),
                      ...matchedSuppliers.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppCard(
                              onTap: () => context.push('/users/supplier-ledger/${s.id}'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: AppTypography.cardTitle),
                                      Text(s.phone, style: AppTypography.bodySecondary),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Payable', style: AppTypography.labelMuted),
                                      Text(AppFormatters.currency(s.currentBalance), style: AppTypography.cardTitle),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (matchedExpenses.isNotEmpty) ...[
                      const Text('Expenses', style: AppTypography.sectionHeading),
                      const SizedBox(height: 8),
                      ...matchedExpenses.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppCard(
                              onTap: () => context.go('/expenses'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(e.title, style: AppTypography.cardTitle),
                                          const SizedBox(width: 6),
                                          AppBadge(label: e.category, variant: BadgeVariant.neutral),
                                        ],
                                      ),
                                      Text(AppFormatters.date(e.date), style: AppTypography.labelMuted),
                                    ],
                                  ),
                                  Text(AppFormatters.currency(e.amount), style: AppTypography.cardTitle),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}
