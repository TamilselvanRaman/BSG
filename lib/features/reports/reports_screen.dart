import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/dashboard_metrics.dart';
import '../../data/models/payment.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedReportIndex = 0;
  String _searchQuery = '';
  String? _selectedLedgerCustomerId;

  final List<String> _reportTypes = [
    'Daily Sales',
    'Initial Payments',
    'Collections',
    'Outstanding Dues',
    'Customer Ledger',
    'Goods Entries',
    'Lot Numbers',
    'Cancelled Bills',
  ];

  final List<IconData> _reportIcons = [
    Icons.point_of_sale,
    Icons.account_balance_wallet,
    Icons.payments_outlined,
    Icons.pending_actions,
    Icons.menu_book,
    Icons.inventory_2_outlined,
    Icons.qr_code,
    Icons.cancel_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final customers = ref.watch(customersProvider);
    final bills = ref.watch(billsProvider);
    final entries = ref.watch(goodsEntriesProvider);
    final payments = ref.watch(paymentsProvider);

    final isWide = context.isTabletOrDesktop;
    final isNarrow = context.screenWidth < 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: 'View Daily Summary',
            onPressed: () => context.push('/reports/daily-summary'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                // Left Desktop Sidebar for Reports
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: AppColors.cardSurface,
                    border: Border(right: BorderSide(color: AppColors.border)),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    itemCount: _reportTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedReportIndex == index;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _reportIcons[index],
                          size: 20,
                          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                        ),
                        title: Text(
                          _reportTypes[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryGreenDark : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.lightGreenSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () {
                          setState(() {
                            _selectedReportIndex = index;
                            _searchQuery = '';
                          });
                        },
                      );
                    },
                  ),
                ),
                // Right Content Area
                Expanded(
                  child: Column(
                    children: [
                      _buildSummaryStrip(metrics, false),
                      const Divider(height: 1),
                      if (_selectedReportIndex != 4) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Filter ${_reportTypes[_selectedReportIndex]} records...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              filled: true,
                              fillColor: AppColors.cardSurface,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: _buildReportContent(customers, bills, entries, payments),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Top Summary Cards Strip
                _buildSummaryStrip(metrics, isNarrow),
                const Divider(height: 1),
                // Horizontal Category Tabs
                Container(
                  color: AppColors.cardSurface,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_reportTypes.length, (index) {
                        final isSelected = _selectedReportIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              _reportIcons[index],
                              size: 16,
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                            ),
                            label: Text(_reportTypes[index]),
                            selected: isSelected,
                            onSelected: (_) => setState(() {
                              _selectedReportIndex = index;
                              _searchQuery = '';
                            }),
                            selectedColor: AppColors.primaryGreen,
                            backgroundColor: AppColors.elevatedSurface,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Search Field
                if (_selectedReportIndex != 4) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Filter report records...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: AppColors.cardSurface,
                      ),
                    ),
                  ),
                ],
                // Active Report Content
                Expanded(
                  child: _buildReportContent(customers, bills, entries, payments),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryStrip(DashboardMetrics metrics, bool isNarrow) {
    if (isNarrow) {
      return Container(
        color: AppColors.cardSurface,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _quickStat(
                    'Active Sales',
                    CurrencyFormatter.format(metrics.todaySales),
                    AppColors.primaryGreen,
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _quickStat(
                    'Initial Advances',
                    CurrencyFormatter.format(metrics.todayInitialPayments),
                    AppColors.initialPaymentBadge,
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
            Row(
              children: [
                Expanded(
                  child: _quickStat(
                    'Collections',
                    CurrencyFormatter.format(metrics.todayTotalCollections),
                    AppColors.accentGreen,
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _quickStat(
                    'Outstanding',
                    CurrencyFormatter.format(metrics.outstandingBuyerBalances),
                    AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.cardSurface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _quickStat(
              'Active Sales',
              CurrencyFormatter.format(metrics.todaySales),
              AppColors.primaryGreen,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _quickStat(
              'Initial Advances',
              CurrencyFormatter.format(metrics.todayInitialPayments),
              AppColors.initialPaymentBadge,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _quickStat(
              'Collections',
              CurrencyFormatter.format(metrics.todayTotalCollections),
              AppColors.accentGreen,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _quickStat(
              'Outstanding',
              CurrencyFormatter.format(metrics.outstandingBuyerBalances),
              AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(
    List<Customer> customers,
    List<Bill> bills,
    List<dynamic> entries,
    List<Payment> payments,
  ) {
    switch (_selectedReportIndex) {
      case 0:
        return _buildDailySalesReport(bills, customers);
      case 1:
        return _buildInitialPaymentsReport(payments, customers);
      case 2:
        return _buildCollectionsReport(payments, customers);
      case 3:
        return _buildOutstandingDuesReport(customers);
      case 4:
        return _buildCustomerLedgerReport(customers);
      case 5:
        return _buildGoodsEntriesReport(entries, customers);
      case 6:
        return _buildLotNumbersReport(entries);
      case 7:
        return _buildCancelledBillsReport(bills, customers);
      default:
        return const Center(child: Text('Select a report'));
    }
  }

  // 1. Daily Sales Report
  Widget _buildDailySalesReport(List<Bill> bills, List<Customer> customers) {
    final activeBills = bills.where((b) {
      if (b.status == BillStatus.cancelled) return false;
      final cust = customers.firstWhere((c) => c.id == b.customerId, orElse: () => customers.first);
      return b.billNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cust.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: activeBills.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final b = activeBills[index];
        final cust = customers.firstWhere((c) => c.id == b.customerId, orElse: () => customers.first);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.billNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${cust.name} (${cust.village})', style: AppTypography.bodySmall),
                    Text(DateFormatter.format(b.billDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.format(b.currentBillTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryGreen)),
                  StatusBadge.fromBillStatus(b.statusLabel),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Initial Payments Report
  Widget _buildInitialPaymentsReport(List<Payment> payments, List<Customer> customers) {
    final initialPays = payments.where((p) {
      if (p.paymentType != PaymentType.initialAdvance) return false;
      final cust = customers.firstWhere((c) => c.id == p.customerId, orElse: () => customers.first);
      return cust.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.reference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.paymentMode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: initialPays.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final p = initialPays[index];
        final cust = customers.firstWhere((c) => c.id == p.customerId, orElse: () => customers.first);

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.initialPaymentBg, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.initialPaymentBadge, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cust.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Mode: ${p.paymentMode}${p.reference.isNotEmpty ? ' • Ref: ${p.reference}' : ''}', style: AppTypography.bodySmall),
                    Text(DateFormatter.formatWithTime(p.paymentDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(CurrencyFormatter.format(p.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.initialPaymentBadge)),
            ],
          ),
        );
      },
    );
  }

  // 3. Collection Report
  Widget _buildCollectionsReport(List<Payment> payments, List<Customer> customers) {
    final filtered = payments.where((p) {
      final cust = customers.firstWhere((c) => c.id == p.customerId, orElse: () => customers.first);
      return cust.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.paymentMode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final p = filtered[index];
        final cust = customers.firstWhere((c) => c.id == p.customerId, orElse: () => customers.first);

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.lightGreenSurface, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.payments_outlined, color: AppColors.accentGreen, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cust.name} • ${p.typeLabel}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${p.paymentMode}${p.reference.isNotEmpty ? ' • ${p.reference}' : ''}', style: AppTypography.bodySmall),
                    Text(DateFormatter.formatWithTime(p.paymentDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(CurrencyFormatter.format(p.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.accentGreen)),
            ],
          ),
        );
      },
    );
  }

  // 4. Outstanding Dues Report
  Widget _buildOutstandingDuesReport(List<Customer> customers) {
    final buyers = customers.where((c) => c.customerType != CustomerType.seller).map((c) {
      final bal = ref.watch(customerBalanceProvider(c.id));
      return {'customer': c, 'balance': bal};
    }).toList();

    buyers.sort((a, b) => (b['balance'] as double).compareTo(a['balance'] as double));

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: buyers.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final c = buyers[index]['customer'] as Customer;
        final bal = buyers[index]['balance'] as double;

        return InkWell(
          onTap: () => context.push('/customers/${c.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: bal > 0 ? AppColors.dangerBg : AppColors.lightGreenSurface,
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: bal > 0 ? AppColors.danger : AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${c.village} • ${c.phone}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(bal.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: bal > 0 ? AppColors.danger : AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      bal > 0 ? 'DUE' : bal < 0 ? 'ADVANCE' : 'SETTLED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: bal > 0 ? AppColors.danger : AppColors.primaryGreen,
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

  // 5. Customer Ledger Report
  Widget _buildCustomerLedgerReport(List<Customer> customers) {
    final buyers = customers.where((c) => c.customerType != CustomerType.seller).toList();
    _selectedLedgerCustomerId ??= buyers.firstOrNull?.id;

    final ledger = _selectedLedgerCustomerId != null
        ? ref.watch(customerLedgerProvider(_selectedLedgerCustomerId!))
        : [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: DropdownButtonFormField<String>(
            value: _selectedLedgerCustomerId,
            hint: const Text('Select Buyer for Ledger Report'),
            items: buyers.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.village})'))).toList(),
            onChanged: (val) => setState(() => _selectedLedgerCustomerId = val),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            ),
          ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.elevatedSurface,
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Date & Ref', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(flex: 2, child: Text('Debit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(flex: 2, child: Text('Credit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(flex: 2, child: Text('Balance', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: ledger.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = ledger[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: index % 2 == 0 ? AppColors.cardSurface : AppColors.background,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormatter.format(row.date), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Text(row.transactionReference, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.debit > 0 ? CurrencyFormatter.format(row.debit) : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: row.debit > 0 ? AppColors.danger : AppColors.textMuted),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.credit > 0 ? CurrencyFormatter.format(row.credit) : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: row.credit > 0 ? AppColors.accentGreen : AppColors.textMuted),
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
                          color: row.runningBalance > 0 ? AppColors.danger : AppColors.primaryGreen,
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

  // 6. Goods Entries Report
  Widget _buildGoodsEntriesReport(List<dynamic> entries, List<Customer> customers) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final e = entries[index];
        final cust = customers.firstWhere((c) => c.id == e.customerId, orElse: () => customers.first);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.entryNumber} • Lot: ${e.lotNumber}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${cust.name} • ${e.goodsName}', style: AppTypography.bodySmall),
                    Text('${e.totalWeight.toStringAsFixed(0)} kg | ${e.goodsCount} bags', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(CurrencyFormatter.format(e.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryGreen)),
            ],
          ),
        );
      },
    );
  }

  // 7. Lot Numbers Report
  Widget _buildLotNumbersReport(List<dynamic> entries) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final e = entries[index];
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightGreenSurface, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.qr_code_2, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.lotNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('${e.goodsName} (${e.totalWeight.toStringAsFixed(0)} kg)', style: AppTypography.bodySmall),
                    if (e.vehicleNumber.isNotEmpty)
                      Text('Vehicle: ${e.vehicleNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(DateFormatter.format(e.entryDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  // 8. Cancelled Bills Report
  Widget _buildCancelledBillsReport(List<Bill> bills, List<Customer> customers) {
    final cancelled = bills.where((b) => b.status == BillStatus.cancelled).toList();

    if (cancelled.isEmpty) {
      return const Center(child: Text('No cancelled bills in record'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: cancelled.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final b = cancelled[index];
        final cust = customers.firstWhere((c) => c.id == b.customerId, orElse: () => customers.first);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b.billNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  StatusBadge.fromBillStatus('Cancelled'),
                ],
              ),
              const SizedBox(height: 4),
              Text('Buyer: ${cust.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('Reversed Bill Amount: ${CurrencyFormatter.format(b.currentBillTotal)}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
              const Divider(height: 12),
              Text('Reason: ${b.cancellationReason}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (b.cancelledAt != null)
                Text('Cancelled by: ${b.cancelledBy} on ${DateFormatter.formatWithTime(b.cancelledAt!)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        );
      },
    );
  }

  Widget _quickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 24, color: AppColors.border);
  }
}
