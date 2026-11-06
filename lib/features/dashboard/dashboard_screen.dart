import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final bills = ref.watch(billsProvider);
    final customers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, Admin',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'BSG Agro Goods Mandi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        actions: [
          // Notification demo icon
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo notification: 2 goods entries ready for billing.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 1300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demo Mode Notice Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Demo Mode: Live calculations powered by local in-memory records.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryGreenDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms),

              const SizedBox(height: AppSpacing.lg),

              // Top Financial Metrics Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width >= 1050 ? 4 : width >= 600 ? 4 : 2;
                  final childAspectRatio = width >= 1050 ? 1.55 : width >= 600 ? 1.35 : 1.22;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: childAspectRatio,
                    children: [
                      KpiCard(
                        title: "Today's Sales",
                        amount: metrics.todaySales,
                        icon: Icons.trending_up,
                        iconColor: AppColors.primaryGreen,
                        iconBgColor: AppColors.lightGreenSurface,
                        subtitle: 'Active issued bills',
                        onTap: () => context.push('/reports'),
                      ),
                      KpiCard(
                        title: 'Initial Payments',
                        amount: metrics.todayInitialPayments,
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.initialPaymentBadge,
                        iconBgColor: AppColors.initialPaymentBg,
                        subtitle: 'Direct advances received',
                        onTap: () => context.push('/reports'),
                      ),
                      KpiCard(
                        title: 'Total Collections',
                        amount: metrics.todayTotalCollections,
                        icon: Icons.payments_outlined,
                        iconColor: AppColors.accentGreen,
                        iconBgColor: AppColors.emeraldTint,
                        subtitle: 'Advances + bill receipts',
                        onTap: () => context.push('/reports'),
                      ),
                      KpiCard(
                        title: 'Outstanding Dues',
                        amount: metrics.outstandingBuyerBalances,
                        icon: Icons.pending_actions_outlined,
                        iconColor: AppColors.pending,
                        iconBgColor: AppColors.pendingBg,
                        subtitle: '${metrics.totalBuyers} active buyers',
                        onTap: () => context.push('/reports'),
                      ),
                    ],
                  );
                },
              ).animate().slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut),

              const SizedBox(height: AppSpacing.xl),

              // Quick Actions Section
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickActionChip(
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'Add Buyer',
                      onTap: () => context.push('/customers/new'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickActionChip(
                      icon: Icons.inventory_2_outlined,
                      label: 'New Goods Entry',
                      onTap: () => context.push('/goods-entries/new'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickActionChip(
                      icon: Icons.receipt_long_outlined,
                      label: 'Create Bill',
                      onTap: () => context.push('/bills/new'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickActionChip(
                      icon: Icons.add_card_outlined,
                      label: 'Record Payment',
                      onTap: () => context.push('/payments/new'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickActionChip(
                      icon: Icons.calendar_today_outlined,
                      label: 'Daily Summary',
                      onTap: () => context.push('/reports/daily-summary'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Responsive Split: Chart & Recent Bills Side-by-Side on Tablet/Desktop
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSplit = constraints.maxWidth >= 960;

                  final chartWidget = Container(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Weekly Sales & Collections',
                                    style: AppTypography.titleMedium,
                                  ),
                                  Text(
                                    'Comparison of sales volume vs cash collected',
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenSurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Last 7 Days',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 120,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                      if (val.toInt() >= 0 && val.toInt() < days.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(days[val.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 34,
                                    getTitlesWidget: (val, meta) {
                                      if (val % 40 == 0) {
                                        return Text('${val.toInt()}k', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 40,
                                getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.borderLight, strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                _makeBarGroup(0, 45, 38),
                                _makeBarGroup(1, 60, 52),
                                _makeBarGroup(2, 75, 68),
                                _makeBarGroup(3, 90, 80),
                                _makeBarGroup(4, 85, 75),
                                _makeBarGroup(5, 110, 95),
                                _makeBarGroup(6, 95, 88),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.md,
                          runSpacing: 4,
                          children: [
                            _LegendIndicator(color: AppColors.primaryGreen, label: 'Sales (₹)'),
                            _LegendIndicator(color: AppColors.accentGreen, label: 'Collections (₹)'),
                          ],
                        ),
                      ],
                    ),
                  );

                  final billsWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Recent Bills',
                        actionLabel: 'View All (${bills.length})',
                        onAction: () => context.go('/bills'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bills.take(4).length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          final customer = customers.cast<dynamic>().firstWhere(
                            (c) => c.id == bill.customerId,
                            orElse: () => null,
                          );

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
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              bill.billNumber,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                            ),
                                            StatusBadge.fromBillStatus(bill.statusLabel),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormatter.format(bill.billDate),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          customer?.name ?? 'Unknown Buyer',
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Total', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                          Text(
                                            CurrencyFormatter.format(bill.currentBillTotal),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (bill.remainingBalance > 0 && bill.status != BillStatus.cancelled)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Due', style: TextStyle(fontSize: 10, color: AppColors.danger)),
                                            Text(
                                              CurrencyFormatter.format(bill.remainingBalance),
                                              style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        )
                                      else if (bill.status == BillStatus.paid)
                                        const Text(
                                          'Settled',
                                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );

                  if (isSplit) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: chartWidget),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 5, child: billsWidget),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      chartWidget,
                      const SizedBox(height: AppSpacing.xl),
                      billsWidget,
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.primaryGreen,
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: AppColors.accentGreen,
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
