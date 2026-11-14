import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/app_repository.dart';

class BillsListScreen extends ConsumerStatefulWidget {
  const BillsListScreen({super.key});

  @override
  ConsumerState<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends ConsumerState<BillsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Bills & Invoices', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.text),
            tooltip: 'Create Bill',
            onPressed: () => _showCreateBillOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Tab bar
          Container(
            color: theme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: theme.text),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search bill number, customer or lot...',
                    hintStyle: TextStyle(color: theme.textMuted),
                    prefixIcon: Icon(Icons.search, size: 20, color: theme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  labelColor: theme.text,
                  unselectedLabelColor: theme.textSecondary,
                  indicatorColor: theme.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  tabs: const [
                    Tab(text: 'All Bills'),
                    Tab(text: 'Cash Bills'),
                    Tab(text: 'Credit Bills'),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBillsList(null),
                _buildBillsList(BillType.cash),
                _buildBillsList(BillType.credit),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primary,
        foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Create Bill', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showCreateBillOptions(context),
      ),
    );
  }

  void _showCreateBillOptions(BuildContext context) {
    final theme = context.appTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Bill', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            const SizedBox(height: 6),
            Text('Select billing workflow type', style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(Icons.payments_outlined, color: theme.primary),
              ),
              title: Text('Cash Bill', style: AppTypography.cardTitle.copyWith(color: theme.text)),
              subtitle: Text('Immediate payment settlement for counter sales', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/bills/create-cash');
              },
            ),
            Divider(color: theme.border),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(Icons.receipt_outlined, color: theme.primary),
              ),
              title: Text('Credit Bill', style: AppTypography.cardTitle.copyWith(color: theme.text)),
              subtitle: Text('Invoice for registered customer with balance due', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/bills/create-credit');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(BillType? typeFilter) {
    final theme = context.appTheme;
    final bills = ref.watch(billsProvider);

    final filtered = bills.where((bill) {
      if (typeFilter != null && bill.type != typeFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return bill.billNumber.toLowerCase().contains(_searchQuery) ||
          bill.customerName.toLowerCase().contains(_searchQuery) ||
          bill.lotNumber.toLowerCase().contains(_searchQuery) ||
          bill.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Bills Found',
        description: 'No bills match the selected category and search query.',
        actionText: 'Create Bill',
        onAction: () => _showCreateBillOptions(context),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bill = filtered[index];
        final isCash = bill.type == BillType.cash;

        return AppCard(
          onTap: () => context.push('/bills/${bill.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(bill.billNumber, style: AppTypography.cardTitle.copyWith(color: theme.text)),
                      const SizedBox(width: 8),
                      AppBadge(
                        label: isCash ? 'CASH' : 'CREDIT',
                        variant: isCash ? BadgeVariant.info : BadgeVariant.warning,
                      ),
                      if (bill.isCancelled) ...[
                        const SizedBox(width: 4),
                        const AppBadge(label: 'CANCELLED', variant: BadgeVariant.error),
                      ],
                    ],
                  ),
                  Text(AppFormatters.date(bill.date), style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              Text(bill.customerName, style: AppTypography.cardTitle.copyWith(fontSize: 15, color: theme.text)),
              const SizedBox(height: 2),
              Text(
                '${bill.productName} • ${AppFormatters.quantity(bill.quantity, bill.unit)} • ${bill.lotNumber}',
                style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rate: ${AppFormatters.currency(bill.sellRate)} / ${bill.unit}',
                    style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                  ),
                  Row(
                    children: [
                      if (bill.balanceDue > 0 && !bill.isCancelled) ...[
                        Text(
                          'Due: ${AppFormatters.currency(bill.balanceDue)}',
                          style: AppTypography.label.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        AppFormatters.currency(bill.totalAmount),
                        style: AppTypography.cardTitle.copyWith(color: theme.text),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
