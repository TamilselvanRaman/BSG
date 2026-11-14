import '../../core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/repositories/app_repository.dart';

class StockSummaryScreen extends ConsumerWidget {
  const StockSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final summaryItems = repo.getStockSummary();

    double totalInward = 0;
    double totalRemaining = 0;
    double totalSold = 0;

    for (final item in summaryItems) {
      totalInward += item.totalInwardQuantity;
      totalRemaining += item.remainingQuantity;
      totalSold += item.soldQuantity;
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Stock Summary', style: AppTypography.pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Create Inward Lot',
            onPressed: () => context.push('/lots/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Aggregate Header Card
          Container(
            color: theme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Warehouse Stock Overview', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Inward', style: AppTypography.labelMuted),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.quantity(totalInward, 'units'),
                              style: AppTypography.cardTitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('In Stock Available', style: AppTypography.labelMuted),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.quantity(totalRemaining, 'units'),
                              style: AppTypography.cardTitle.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Sold', style: AppTypography.labelMuted),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.quantity(totalSold, 'units'),
                              style: AppTypography.cardTitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Product Wise Stock List
          Expanded(
            child: summaryItems.isEmpty
                ? AppEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Stock Recorded',
                    description: 'Create an inward lot to start tracking warehouse stock.',
                    actionText: 'Create Lot',
                    onAction: () => context.push('/lots/create'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: summaryItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = summaryItems[index];
                      final percentRemaining = item.totalInwardQuantity > 0
                          ? (item.remainingQuantity / item.totalInwardQuantity).clamp(0.0, 1.0)
                          : 0.0;

                      return AppCard(
                        onTap: () => context.push('/lots'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.productName, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                                AppBadge(
                                  label: '${item.activeLotsCount} active lots',
                                  variant: item.remainingQuantity > 0 ? BadgeVariant.success : BadgeVariant.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentRemaining,
                                minHeight: 6,
                                backgroundColor: theme.accent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentRemaining > 0.25 ? AppColors.primaryAction : AppColors.warning,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Remaining', style: AppTypography.labelMuted),
                                    Text(
                                      AppFormatters.quantity(item.remainingQuantity, item.unit),
                                      style: AppTypography.cardTitle,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Sold', style: AppTypography.labelMuted),
                                    Text(
                                      AppFormatters.quantity(item.soldQuantity, item.unit),
                                      style: AppTypography.body,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total Inward', style: AppTypography.labelMuted),
                                    Text(
                                      AppFormatters.quantity(item.totalInwardQuantity, item.unit),
                                      style: AppTypography.bodySecondary,
                                    ),
                                  ],
                                ),
                              ],
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
