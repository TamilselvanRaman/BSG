import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../seller_loads/seller_history_screen.dart';
import 'add_customer_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == widget.customerId,
      orElse: () => null,
    );

    if (customer == null) {
      final loads = ref.watch(sellerLoadsProvider);
      final hasLoad = loads.any((l) => l.sellerId == widget.customerId || l.id == widget.customerId || l.loadNumber == widget.customerId);
      if (hasLoad) {
        return SellerHistoryScreen(sellerId: widget.customerId);
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer not found')),
      );
    }

    final balance = ref.watch(customerBalanceProvider(customer.id));
    final bills = ref.watch(billsProvider).where((b) => b.customerId == customer.id).toList();
    final entries = ref.watch(goodsEntriesProvider).where((e) => e.customerId == customer.id).toList();
    final payments = ref.watch(paymentsProvider).where((p) => p.customerId == customer.id).toList();
    final ledger = ref.watch(customerLedgerProvider(customer.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddCustomerScreen(initialCustomer: customer),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            const Tab(text: 'Overview'),
            Tab(text: 'Goods Entries (${entries.length})'),
            Tab(text: 'Bills (${bills.length})'),
            Tab(text: 'Payments (${payments.length})'),
            Tab(text: 'Account Ledger (${ledger.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview Tab
          ResponsiveContainer(maxWidth: 1100, padding: EdgeInsets.zero, child: _buildOverviewTab(customer, balance, bills, entries, payments)),

          // 2. Goods Entries Tab
          ResponsiveContainer(maxWidth: 1100, padding: EdgeInsets.zero, child: _buildEntriesTab(entries)),

          // 3. Bills Tab
          ResponsiveContainer(maxWidth: 1100, padding: EdgeInsets.zero, child: _buildBillsTab(bills)),

          // 4. Payments Tab
          ResponsiveContainer(maxWidth: 1100, padding: EdgeInsets.zero, child: _buildPaymentsTab(payments)),

          // 5. Account Ledger Tab
          ResponsiveContainer(maxWidth: 1100, padding: EdgeInsets.zero, child: _buildLedgerTab(ledger, customer)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    Customer customer,
    double balance,
    List<Bill> bills,
    List<dynamic> entries,
    List<dynamic> payments,
  ) {
    final totalBilled = bills
        .where((b) => b.status != BillStatus.cancelled)
        .fold(0.0, (sum, b) => sum + b.currentBillTotal);

    final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outstanding Balance Hero Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: balance > 0
                  ? AppColors.pendingBg
                  : balance < 0
                      ? AppColors.lightGreenSurface
                      : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: balance > 0
                    ? AppColors.pending.withValues(alpha: 0.3)
                    : balance < 0
                        ? AppColors.primaryGreen.withValues(alpha: 0.3)
                        : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance > 0
                          ? 'Current Outstanding Due'
                          : balance < 0
                              ? 'Unapplied Advance Credit'
                              : 'Account Settled',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: balance > 0
                            ? AppColors.pending
                            : balance < 0
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(balance.abs()),
                      style: AppTypography.currencyLarge.copyWith(
                        color: balance > 0
                            ? AppColors.danger
                            : balance < 0
                                ? AppColors.primaryGreen
                                : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    balance > 0
                        ? Icons.pending_actions_outlined
                        : balance < 0
                            ? Icons.verified_outlined
                            : Icons.check_circle_outline,
                    color: balance > 0
                        ? AppColors.pending
                        : balance < 0
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Contact & Profile Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile Details', style: AppTypography.titleMedium),
                    StatusBadge.fromCustomerType(customer.customerType.name),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _infoRow(Icons.location_on_outlined, 'Village / Location', customer.village),
                _infoRow(Icons.phone_outlined, 'Phone Number', customer.phone),
                _infoRow(
                  Icons.account_balance_outlined,
                  'Opening Balance',
                  CurrencyFormatter.format(customer.openingBalance),
                ),
                if (customer.notes.isNotEmpty)
                  _infoRow(Icons.notes_outlined, 'Notes', customer.notes),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Financial Summary 2x2
          Row(
            children: [
              Expanded(
                child: _miniStatCard('Total Active Sales', CurrencyFormatter.format(totalBilled), Icons.trending_up, AppColors.primaryGreen),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _miniStatCard('Total Collections', CurrencyFormatter.format(totalPaid), Icons.payments_outlined, AppColors.accentGreen),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Record Payment',
                  onPressed: () => context.push('/payments/new'),
                  icon: Icons.add_card,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Create Bill',
                  isOutlined: true,
                  onPressed: () => context.push('/bills/new'),
                  icon: Icons.receipt_long,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildEntriesTab(List<dynamic> entries) {
    if (entries.isEmpty) {
      return EmptyStateView(
        icon: Icons.inventory_2_outlined,
        title: 'No Goods Entries',
        description: 'No goods entries recorded for this buyer yet.',
        buttonLabel: 'New Goods Entry',
        onButtonPressed: () => context.push('/goods-entries/new'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return InkWell(
          onTap: () => context.push('/goods-entries/${entry.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.entryNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(DateFormatter.format(entry.entryDate), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.goodsName} (Lot: ${entry.lotNumber})',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${entry.totalWeight.toStringAsFixed(0)} kg | ${entry.goodsCount} bags', style: AppTypography.bodySmall),
                    Text(
                      CurrencyFormatter.format(entry.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
                if (entry.initialPaymentAmount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.initialPaymentBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Initial Payment Received: ${CurrencyFormatter.format(entry.initialPaymentAmount)} (${entry.initialPaymentMode})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.initialPaymentBadge),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillsTab(List<Bill> bills) {
    if (bills.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: 'No Bills Generated',
        description: 'No bills have been generated for this buyer yet.',
        buttonLabel: 'Create Bill',
        onButtonPressed: () => context.push('/bills/new'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: bills.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final bill = bills[index];
        return InkWell(
          onTap: () => context.push('/bills/${bill.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(bill.billNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(width: 8),
                        StatusBadge.fromBillStatus(bill.statusLabel),
                      ],
                    ),
                    Text(DateFormatter.format(bill.billDate), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Bill Total:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(bill.currentBillTotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                if (bill.initialPaymentApplied > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Initial Advance Deducted:', style: TextStyle(fontSize: 12, color: AppColors.initialPaymentBadge)),
                      Text('- ${CurrencyFormatter.format(bill.initialPaymentApplied)}', style: const TextStyle(fontSize: 12, color: AppColors.initialPaymentBadge, fontWeight: FontWeight.w600)),
                    ],
                  ),
                if (bill.otherPaymentsApplied > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Other Payments Applied:', style: TextStyle(fontSize: 12, color: AppColors.accentGreen)),
                      Text('- ${CurrencyFormatter.format(bill.otherPaymentsApplied)}', style: const TextStyle(fontSize: 12, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
                    ],
                  ),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remaining Due:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      CurrencyFormatter.format(bill.remainingBalance),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: bill.remainingBalance > 0 ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(List<dynamic> payments) {
    if (payments.isEmpty) {
      return EmptyStateView(
        icon: Icons.payments_outlined,
        title: 'No Payments Recorded',
        description: 'No payments have been received for this customer yet.',
        buttonLabel: 'Record Payment',
        onButtonPressed: () => context.push('/payments/new'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final payment = payments[index];
        final isAdvance = payment.paymentType.toString().contains('initialAdvance');

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAdvance ? AppColors.initialPaymentBg : AppColors.lightGreenSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isAdvance ? Icons.account_balance_wallet_outlined : Icons.check_circle_outline,
                  color: isAdvance ? AppColors.initialPaymentBadge : AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(payment.typeLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(payment.paymentMode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(DateFormatter.formatWithTime(payment.paymentDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    if (payment.reference.isNotEmpty)
                      Text('Ref: ${payment.reference}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(payment.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.accentGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLedgerTab(List<dynamic> ledger, Customer customer) {
    if (ledger.isEmpty) {
      return const EmptyStateView(
        icon: Icons.account_balance_outlined,
        title: 'Empty Account Ledger',
        description: 'No ledger transactions recorded yet.',
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.elevatedSurface,
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Date & Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
              Expanded(flex: 2, child: Text('Debit (+)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
              Expanded(flex: 2, child: Text('Credit (-)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
              Expanded(flex: 2, child: Text('Balance', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
            ],
          ),
        ),
        const Divider(height: 1),

        // Ledger Records
        Expanded(
          child: ListView.separated(
            itemCount: ledger.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = ledger[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: index % 2 == 0 ? AppColors.cardSurface : AppColors.background,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormatter.format(row.date), style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(row.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(row.transactionReference, style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.debit > 0 ? CurrencyFormatter.format(row.debit) : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: row.debit > 0 ? AppColors.danger : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.credit > 0 ? CurrencyFormatter.format(row.credit) : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: row.credit > 0 ? AppColors.accentGreen : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        CurrencyFormatter.format(row.runningBalance),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: row.runningBalance > 0
                              ? AppColors.danger
                              : row.runningBalance < 0
                                  ? AppColors.primaryGreen
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
