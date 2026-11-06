import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/kpi_card.dart';
import '../../data/app_state.dart';

class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final summary = ref.watch(dailySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Financial Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Select Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).setDate(picked);
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Date Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormatter.format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).setDate(
                              selectedDate.subtract(const Duration(days: 1)));
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).setDate(DateTime.now());
                        },
                        child: const Text('Today', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).setDate(
                              selectedDate.add(const Duration(days: 1)));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Daily Financial Totals Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: isWide ? 1.4 : 1.2,
                  children: [
                    KpiCard(
                      title: 'Active Sales',
                      amount: summary.activeSalesTotal,
                      icon: Icons.trending_up,
                      iconColor: AppColors.primaryGreen,
                      iconBgColor: AppColors.lightGreenSurface,
                      subtitle: '${summary.billsCount} active bills',
                    ),
                    KpiCard(
                      title: 'Initial Advances',
                      amount: summary.initialPaymentsReceived,
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.initialPaymentBadge,
                      iconBgColor: AppColors.initialPaymentBg,
                      subtitle: 'Direct vehicle advances',
                    ),
                    KpiCard(
                      title: 'Total Collections',
                      amount: summary.totalCollections,
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.accentGreen,
                      iconBgColor: AppColors.emeraldTint,
                      subtitle: 'Advances + bill receipts',
                    ),
                    KpiCard(
                      title: 'Day Outstanding',
                      amount: summary.outstandingBalance,
                      icon: Icons.pending_actions_outlined,
                      iconColor: AppColors.pending,
                      iconBgColor: AppColors.pendingBg,
                      subtitle: '${summary.cancelledBillsCount} cancelled bills',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Daily Operations Summary Strip
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Goods Lots', '${summary.goodsEntriesCount} Entries', Icons.inventory_2_outlined),
                  _divider(),
                  _statItem('Billed Invoices', '${summary.billsCount} Bills', Icons.receipt_long_outlined),
                  _divider(),
                  _statItem('Cancelled', '${summary.cancelledBillsCount} Bills', Icons.cancel_outlined, color: AppColors.danger),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Itemized Transaction Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Transactions Breakdown', style: AppTypography.titleMedium),
                Text(
                  '${summary.transactions.length} Records',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (summary.transactions.isEmpty) ...[
              const EmptyStateView(
                icon: Icons.event_busy_outlined,
                title: 'No Transactions for this Date',
                description: 'No sales, entries or collections were recorded on this day.',
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summary.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final tx = summary.transactions[index];

                  Color typeColor = AppColors.primaryGreen;
                  Color typeBg = AppColors.lightGreenSurface;
                  IconData icon = Icons.receipt_outlined;

                  if (tx.type.contains('Initial')) {
                    typeColor = AppColors.initialPaymentBadge;
                    typeBg = AppColors.initialPaymentBg;
                    icon = Icons.account_balance_wallet_outlined;
                  } else if (tx.type.contains('Payment')) {
                    typeColor = AppColors.accentGreen;
                    typeBg = AppColors.emeraldTint;
                    icon = Icons.payments_outlined;
                  } else if (tx.type.contains('Cancel')) {
                    typeColor = AppColors.danger;
                    typeBg = AppColors.dangerBg;
                    icon = Icons.cancel_outlined;
                  } else if (tx.type.contains('Goods')) {
                    typeColor = AppColors.infoBlue;
                    typeBg = AppColors.infoBg;
                    icon = Icons.inventory_2_outlined;
                  }

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
                            color: typeBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Icon(icon, color: typeColor, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tx.type,
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: typeColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tx.referenceNumber,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tx.customerName} (${tx.village})',
                                style: AppTypography.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (tx.vehicleNumber != null)
                                Text('Vehicle: ${tx.vehicleNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(tx.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: tx.type.contains('Cancel') ? AppColors.textMuted : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tx.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: tx.type.contains('Cancel') ? AppColors.danger : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    ),
  );
}

  Widget _statItem(String title, String val, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color ?? AppColors.textPrimary)),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}
