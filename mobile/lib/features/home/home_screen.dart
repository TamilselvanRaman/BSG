import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/lot_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_image_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final allProducts = ref.watch(productsProvider);
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: RefreshIndicator(
        color: theme.primary,
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: 6 Big Box Actions
              Text(
                'Quick Actions',
                style: AppTypography.sectionHeading.copyWith(color: theme.text),
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context, theme),

              const SizedBox(height: AppSpacing.sectionGap),

              // Section 2: Financial Snapshot KPIs (Today's Overview)
              Text(
                "Today's Overview",
                style: AppTypography.sectionHeading.copyWith(color: theme.text),
              ),
              const SizedBox(height: 12),
              _buildKpiGrid(summary, theme),

              const SizedBox(height: AppSpacing.sectionGap),

              // Section 3: Recent Bills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bills',
                    style: AppTypography.sectionHeading.copyWith(color: theme.text),
                  ),
                  TextButton(
                    onPressed: () => context.go('/bills'),
                    child: Text(
                      'View All',
                      style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (summary.recentBills.isEmpty)
                _buildEmptyRow('No bills recorded today', theme)
              else
                ...summary.recentBills.map((bill) => _buildBillItem(context, bill, allProducts, theme)),

              const SizedBox(height: AppSpacing.sectionGap),

              // Section 4: Recent Lots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Lots',
                    style: AppTypography.sectionHeading.copyWith(color: theme.text),
                  ),
                  TextButton(
                    onPressed: () => context.push('/lots'),
                    child: Text(
                      'View Lots',
                      style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (summary.recentLots.isEmpty)
                _buildEmptyRow('No lots created yet', theme)
              else
                ...summary.recentLots.map((lot) => _buildLotItem(context, lot, allProducts, theme)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, AppThemeColors theme) {
    final actions = [
      _QuickAction(
        title: 'Create Cash Bill',
        subtitle: 'Counter sale & receipt',
        icon: Icons.payments_outlined,
        onTap: () => context.push('/bills/create-cash'),
      ),
      _QuickAction(
        title: 'Create Credit Bill',
        subtitle: 'Customer ledger invoice',
        icon: Icons.receipt_long_outlined,
        onTap: () => context.push('/bills/create-credit'),
      ),
      _QuickAction(
        title: 'Received Amount',
        subtitle: 'Collect customer payment',
        icon: Icons.arrow_downward_rounded,
        onTap: () => context.push('/payments/received-amount'),
      ),
      _QuickAction(
        title: 'Create Lot',
        subtitle: 'Inward farm arrivals',
        icon: Icons.add_box_outlined,
        onTap: () => context.push('/lots/create'),
      ),
      _QuickAction(
        title: 'Users Directory',
        subtitle: 'Suppliers & customers',
        icon: Icons.people_alt_outlined,
        onTap: () => context.go('/users'),
      ),
      _QuickAction(
        title: 'Add Expense',
        subtitle: 'Labour, freight & rent',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => context.go('/expenses'),
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < actions.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < actions.length ? 10 : 0),
            child: Row(
              children: [
                Expanded(child: _buildBigActionBox(actions[i], theme)),
                const SizedBox(width: 10),
                Expanded(child: _buildBigActionBox(actions[i + 1], theme)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBigActionBox(_QuickAction act, AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: act.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(act.icon, size: 20, color: theme.text),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: theme.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            act.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle.copyWith(fontSize: 14.5, color: theme.text),
          ),
          const SizedBox(height: 3),
          Text(
            act.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(dynamic summary, AppThemeColors theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Total Sales',
                amount: AppFormatters.currency(summary.dailyTotalSales),
                subtext: 'Cash: ${AppFormatters.currency(summary.dailyCashSales, showDecimals: false)} | Credit: ${AppFormatters.currency(summary.dailyCreditSales, showDecimals: false)}',
                icon: Icons.trending_up_rounded,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'Received Amount',
                amount: AppFormatters.currency(summary.dailyReceivedAmount),
                subtext: 'Cash collections & receipts',
                icon: Icons.check_circle_outline_rounded,
                accentColor: theme.success,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Customer Outstanding',
                amount: AppFormatters.currency(summary.totalOutstanding),
                subtext: 'Total balance receivables',
                icon: Icons.schedule_rounded,
                accentColor: theme.warning,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'Daily Expenses',
                amount: AppFormatters.currency(summary.dailyExpenses),
                subtext: 'Labour, transport & ops',
                icon: Icons.account_balance_wallet_outlined,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String amount,
    required String subtext,
    required IconData icon,
    Color? accentColor,
    required AppThemeColors theme,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(color: theme.textSecondary),
              ),
              Icon(icon, size: 16, color: accentColor ?? theme.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTypography.amount.copyWith(
              color: accentColor ?? theme.text,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(BuildContext context, Bill bill, List<Product> allProducts, AppThemeColors theme) {
    final isCash = bill.type == BillType.cash;

    // Resolve matching product thumbnail
    final name = bill.productName.toLowerCase();
    final matched = allProducts.where((p) {
      final pName = p.name.toLowerCase();
      return name.contains(pName) || pName.contains(name);
    }).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => context.push('/bills/${bill.id}'),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.isDark ? theme.surface : Colors.white,
                border: Border.all(
                  color: (isCash ? theme.primary : theme.warning).withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: matched != null
                    ? ClipOval(
                        child: ProductImageView(
                          assetPath: matched.assetPath,
                          imageUrl: matched.imageUrl,
                          size: 38,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(
                        isCash ? Icons.point_of_sale_outlined : Icons.receipt_outlined,
                        size: 20,
                        color: theme.primary,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bill.billNumber,
                        style: AppTypography.cardTitle.copyWith(color: theme.text),
                      ),
                      const SizedBox(width: 8),
                      AppBadge(
                        label: isCash ? 'CASH' : 'CREDIT',
                        variant: isCash ? BadgeVariant.info : BadgeVariant.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bill.customerName,
                    style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary),
                  ),
                  Text(
                    '${bill.productName} • ${AppFormatters.quantity(bill.quantity, bill.unit)}',
                    style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(bill.totalAmount),
                  style: AppTypography.cardTitle.copyWith(color: theme.text),
                ),
                Text(
                  AppFormatters.date(bill.date),
                  style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotItem(BuildContext context, Lot lot, List<Product> allProducts, AppThemeColors theme) {
    // Resolve product image
    String? assetPath;
    String? imageUrl;

    if (lot.items.isNotEmpty && (lot.items.first.assetPath != null || lot.items.first.imageUrl != null)) {
      assetPath = lot.items.first.assetPath;
      imageUrl = lot.items.first.imageUrl;
    } else {
      final name = lot.productName.toLowerCase();
      final matched = allProducts.where((p) {
        final pName = p.name.toLowerCase();
        return name.contains(pName) || pName.contains(name);
      }).firstOrNull;
      if (matched != null) {
        assetPath = matched.assetPath;
        imageUrl = matched.imageUrl;
      }
    }

    final remainingRatio = lot.initialQuantity > 0
        ? (lot.remainingQuantity / lot.initialQuantity).clamp(0.0, 1.0)
        : 0.0;
    final percentRemaining = (remainingRatio * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _showLotActionSheet(context, lot, theme, assetPath, imageUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Produce Thumbnail with themed ring
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.isDark ? theme.surface : Colors.white,
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: theme.isDark ? 0.2 : 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipOval(
                      child: ProductImageView(
                        assetPath: assetPath,
                        imageUrl: imageUrl,
                        size: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Lot Number, Product Title & Supplier
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            lot.lotNumber,
                            style: AppTypography.cardTitle.copyWith(
                              color: theme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge(
                            label: lot.isAvailable ? 'Available' : 'Sold Out',
                            variant: lot.isAvailable ? BadgeVariant.success : BadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lot.productName,
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 13, color: theme.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lot.supplierName,
                              style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Remaining Quantity on Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.quantity(lot.remainingQuantity, lot.unit),
                      style: AppTypography.cardTitle.copyWith(
                        color: theme.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of ${AppFormatters.quantity(lot.initialQuantity, lot.unit)}',
                      style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Stock Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: remainingRatio,
                      backgroundColor: theme.accent,
                      valueColor: AlwaysStoppedAnimation(
                        remainingRatio > 0.3 ? theme.primary : theme.warning,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentRemaining% in stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLotActionSheet(
    BuildContext context,
    Lot lot,
    AppThemeColors theme,
    String? assetPath,
    String? imageUrl,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.isDark ? theme.surface : Colors.white,
                      border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Center(
                      child: ClipOval(
                        child: ProductImageView(
                          assetPath: assetPath,
                          imageUrl: imageUrl,
                          size: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              lot.lotNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${AppFormatters.quantity(lot.remainingQuantity, lot.unit)} left',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lot.productName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Action 1: Create Cash Bill
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.payments_outlined, color: theme.primary, size: 20),
                ),
                title: Text('Create Cash Bill', style: TextStyle(fontWeight: FontWeight.w600, color: theme.text)),
                subtitle: Text('Sell directly from this lot with cash receipt', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                trailing: Icon(Icons.chevron_right, color: theme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/bills/create-cash?lotId=${lot.id}');
                },
              ),

              // Action 2: Create Credit Bill
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long_outlined, color: theme.warning, size: 20),
                ),
                title: Text('Create Credit Bill', style: TextStyle(fontWeight: FontWeight.w600, color: theme.text)),
                subtitle: Text('Add to buyer customer ledger balance', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                trailing: Icon(Icons.chevron_right, color: theme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/bills/create-credit?lotId=${lot.id}');
                },
              ),

              // Action 3: Lot-Based Billing (Bags & Weight)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.scale_rounded, color: Colors.purple, size: 20),
                ),
                title: Text('Lot-Based Goods Billing', style: TextStyle(fontWeight: FontWeight.w600, color: theme.text)),
                subtitle: Text('Multi-bag weighbridge & mandi charges workflow', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                trailing: Icon(Icons.chevron_right, color: theme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/bills/lot-billing?lotId=${lot.id}');
                },
              ),

              // Action 4: View Lot Details
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: theme.textMuted, size: 20),
                ),
                title: Text('View Lot Consignment Details', style: TextStyle(fontWeight: FontWeight.w600, color: theme.text)),
                subtitle: Text('Consignment overview, bag counts & sold history', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                trailing: Icon(Icons.chevron_right, color: theme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/lots/${lot.id}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRow(String message, AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        message,
        style: AppTypography.bodySecondary.copyWith(color: theme.textMuted),
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
